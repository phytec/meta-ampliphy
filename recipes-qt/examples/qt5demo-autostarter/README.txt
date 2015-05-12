Note: Keep service units in folder

    mx6/qt5demo.service and in
    ti33x/qt5demo.service

in sync! The only difference is the dependence on the service pvr-init

    Requires=pvr-init.service
    After=pvr-init.service

in 'ti33x/qt5demo.service', because it doesn't exists on i.MX6 platforms and is
needed on ti33x platforms.
