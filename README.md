# FOC-FPGA-HB
Scalable Multi-Axis FOC on FPGA for Permanent Magnet Synchronous Motors

Board used: TE0720-04-61C33MAS

Software Version: Vivado 2020.2, Vitis 2020.2

Brief description of project: The project includes a Field-Oriented Control Core that can control multiple BLDC motors. The core utilizes pipelining to share logic and optimize the system's scalability. 

Video: https://youtu.be/ibGOrkTTE68
 

Description of archive (explain directory structure, documents and source files):
```bash
├─ FOC-FPGA-HB/      # Folder containing FOC core
|  ├─ RTL/           # Folder containing files used within the project
|  |  ├─ src/        # source folder for core
|  |  |   └─ python/ # Python files to generate LUT
|  |  └─ xdc/        # xdc files
|  └─ Hardware.md    # Hardware utilized in testing of FOC core
├─ .gitignore        # Gitignore file
├─ LICENSE           # MIT License
├─ Master_Thesis.pdf # Master thesis
├─ Short_report_FOC  # Short project report. Fore complete data, look at the Thesis
└─ README.md         # Readme file containing information about the current repo
```

Instructions to build and test project

Step 1: Start a new project in Vivado.

Step 2: Import the vhdl files and ".txt" files for lookup tables.

Step 3: Select VHDL 2008 as the programming language.

Step 4: Add compatibility layer around the core.
(If the SoC is to be used a Block design in Vivado would need implementation)

Step 5: Constrain the design

Step 6: Generate bitstream.

The example included works for 2 BLDC motors on a the TE0720-04-61C33MAS.
The TCL file does not work as there was some problems with relative path during the creation of the script.

For more information about the code, read the thesis provided.
