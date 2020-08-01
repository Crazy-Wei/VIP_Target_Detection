# Frame_Difference
2020年新工科联盟-Xilinx暑期学校（Summer School）项目

This project implements a moving target detection system on the PYNQ-z2 platform. It uses the video stream signal transmitted by the OV7725 camera, then processes the image and output the moving target to the LCD monitor to display.

## Quick Instructions
Here are instructions about how to setup this moving target detection system on your PYNQ-z2 board.

### Prerequisites
- Xilinx Vivado 2018.3.
- PYNQ-z2 Development Board.
- A OV7725 camera.
- A LCD monitor.

This project is developed and tested with Xilinx Vivado Suite 2018.3, but it can work with newer versions.

### Build Vivado Project
You can "source" scripts in your Vivado Tcl Console to build the Vivado project. These scripts will import RTL files, third-part IPs and other necessary files.

```tcl
cd $REPO_PATH
set argv [list project=Frame_Difference sdk=yes version_override=yes]
set argc [llength $argv]
source "make.tcl" -notrace
```

After creating your project, you should change the ip path, you need to change the ip path to the ip path you downloaded.

- Click "Settings" button.
- Click "Repository" button under "IP" directory.
- Change the ip path to your own path "$REPO_PATH/ip_rope".

![set ip path](./img/set_ip_path.png)

Then you should add the "main.c" file to SDK, which is under the "$REPO_PATH/sdk" directory.

![add source](./img/add_source.png)

## Contributors
- Zhiwei Zhou ([@Crazy-Wei](https://github.com/Crazy-Wei))
- Junpeng Chen ([@bird1and1fish](https://github.com/bird1and1fish))