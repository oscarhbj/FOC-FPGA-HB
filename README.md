# FOC-FPGA-HB
Scalable Multi-Axis FOC on FPGA for Permanent Magnet Synchronous Motors

Board used: TE0720-04-61C33MAS

Software Version: Vivado 2020.2, Vitis 2020.2

Brief description of project: The project includes a Field-Oriented Control Core that can control multiple BLDC motors. The core utilizes pipelining to share logic and optimize the system's scalability. 

 

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
└─ README.md         # Readme file containing information about the current repo
```

Instructions to build and test project

Step 1:
