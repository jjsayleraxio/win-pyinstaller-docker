# win-pyinstaller-docker

This project creates a docker container to run pyinstaller and create Windows executables from python scripts.

Current version of Python used is: **3.7.3**

Current version of Pyinstaller used is: **3.5**

How to use:
```
docker run --rm -v "$(pwd):/src/" jjsaxio/win-pyinstaller-docker
```

This will create an instance of the container with your current working directory mounted as src. The entrypoint.sh script will look for a pyinstaller .spec file and a requirements.txt file to use in generating your Windows executable. It will place your new executable within the ```dist/windows/``` folder in your present working directory. The .exe file will have the same name as your .spec file. Once everything is finished, --rm will remove the container from your system. See [here](https://github.com/cdrx/docker-pyinstaller) for further information.

The development version has entrypoint, allowing for any command to be run instead of the entrypoint.sh script:

```
docker run --rm -it -v "$(pwd):/src/" jjsaxio/win-pyinstaller-docker bash
```

***

This project is based on [docker-pyinstaller](https://github.com/cdrx/docker-pyinstaller). Thank you @cdrx for all your hard work!
