Note: Keep service units in machine override folders

    ti33x/qt5demo.service

in sync with the baseline service!
The only difference at the moment is the dependency on the service pvr-init

    Requires=pvr-init.service
    After=pvr-init.service

in 'ti33x/qt5demo.service', because it doesn't exists on i.MX6 platforms and is
needed on ti33x platforms.
