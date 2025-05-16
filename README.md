# MPL-Sem4-Practical SPPU

🛠️ How to Run Assembly Programs

Follow the steps below to clone this repository and run any .asm file using NASM (Netwide Assembler) and the GNU Linker.
📦 Prerequisites
Make sure you have the following installed on your system:
    NASM – Netwide Assembler
    LD – GNU Linker (comes with binutils)

You can install them using:

sudo apt update
sudo apt install nasm build-essential

📥 Step 1: Clone the Repository

git clone https://github.com/Disha-Gaikwad/MPL-Sem4-Practical.git
cd  MPL-Sem4-Practical

📁 Step 2: Navigate to the Program Directory

cd path/to/your/asm/file

Example:
cd programs/hello-world

⚙️ Step 3: Assemble and Link the Program

For 64-bit Linux:

nasm -f elf64 filename.asm -o filename.o
ld filename.o -o filename

For 32-bit Linux:

nasm -f elf filename.asm -o filename.o
ld -m elf_i386 filename.o -o filename

Make sure to use the correct format (elf for 32-bit, elf64 for 64-bit) based on your system and the source code.

▶️ Step 4: Run the Executable

./filename

📌 Example

nasm -f elf64 hello.asm -o hello.o
ld hello.o -o hello
./hello

🧼 Clean Up (Optional)

rm *.o filename

🧠 Notes

    If your program uses system calls, make sure it's compatible with your architecture.

    Use strace ./filename to debug syscalls if the output isn't as expected.
