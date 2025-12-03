#include <iostream>
#include <stdlib.h>
using namespace std;

int main(int argc, char const *argv[])
{
    if (argc != 2)
    {
        cout << "Error: Usage is mk <cpp_file> !" << endl;
        return -1;
    }
    string cpp_file = argv[1];
    string cmd = "g++ " + cpp_file + " -o test -std=c++11";

    cout << "cmd: " << cmd << endl;
    system(cmd.c_str());

    return 0;
}
