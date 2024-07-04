#!/usr/bin/env bash

Install_ImageMagic()
{
    echo "====== Installing ImageMagic ======"
    Press_Start

    rm -f ${PHP_Path}/conf.d/008-imagick.ini
    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}imagick.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    if [ "$PM" = "yum" ]; then
        if [ "${DISTRO}" = "Oracle" ]; then
            yum -y install oracle-epel-release
        else
            yum -y install epel-release
        fi
        Get_Dist_Version
        if [ "${country}" = "CN" ]; then
            sed -e 's!^metalink=!#metalink=!g' \
                -e 's!^#baseurl=!baseurl=!g' \
                -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
                -e 's!//download\.example/pub!//mirrors.ustc.edu.cn!g' \
                -i /etc/yum.repos.d/epel*.repo
        fi
        yum install -y libwebp-devel
    elif [ "$PM" = "apt" ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y libwebp-dev
    fi
    ldconfig

    cd ${cur_dir}/src
    if [ -s /usr/local/imagemagick/bin/convert ]; then
        echo "ImageMagick already exists."
    else
        if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.';then
            Download_Files https://imagemagick.org/archive/releases/ImageMagick-6.9.9-51.tar.xz ImageMagick-6.9.9-51.tar.xz
            Tar_Cd ImageMagick-6.9.9-27.tar.gz ImageMagick-6.9.9-27
        else
            Download_Files https://imagemagick.org/archive/releases/${ImageMagick_Ver}.tar.xz ${ImageMagick_Ver}.tar.xz
            Tar_Cd ${ImageMagick_Ver}.tar.xz ${ImageMagick_Ver}
        fi

        ./configure --prefix=/usr/local/imagemagick
        Make_Install
        cd ../
        rm -rf ${cur_dir}/src/${ImageMagick_Ver}
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.';then
        Download_Files https://pecl.php.net/get/imagick-3.1.2.tgz imagick-3.1.2.tgz
        Tar_Cd imagick-3.1.2.tgz imagick-3.1.2
    else
        Download_Files https://pecl.php.net/get/${Imagick_Ver}.tgz ${Imagick_Ver}.tgz
        Tar_Cd ${Imagick_Ver}.tgz ${Imagick_Ver}
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config --with-imagick=/usr/local/imagemagick
    Make_Install
    cd ../

    cat >${PHP_Path}/conf.d/008-imagick.ini<<EOF
extension = "imagick.so"
EOF

    if [ -s "${zend_ext}" ] && [ -s /usr/local/imagemagick/bin/convert ]; then
        Restart_PHP
        Echo_Green "====== ImageMagick install completed ======"
        Echo_Green "ImageMagick installed successfully, enjoy it!"
    else
        rm -f ${PHP_Path}/conf.d/008-imagick.ini
        Echo_Red "imagick install failed!"
    fi
}

Uninstall_ImageMagick()
{
    echo "You will uninstall ImageMagick..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/008-imagick.ini
    echo "Delete ImageMagick directory..."
    rm -rf /usr/local/imagemagick
    Restart_PHP
    Echo_Green "Uninstall ImageMagick completed."
}
