Note: Keep service units in machine override folders

    ti33x/phytec-qtdemo.service

in sync with the baseline service!
The differences for ti33x are:

- dependency on pvr-init.service
- framebuffer reattach cannot be used as it crashes
- so we need another workaround for the blinking cursor
