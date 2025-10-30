#include <iostream>

void moveToX(float value)
{
    std::cout << "moveToX " << value;
    std::cin.get();
}

void moveToY(float value)
{
    std::cout << "moveToY " << value;
    std::cin.get();
}

void moveToZ(float value)
{
    std::cout << "moveToZ " << value;
    std::cin.get();
}

void moveToXY(float x, float y)
{
    std::cout << "moveTo " << x << " " << y;
    std::cin.get();
}

void moveToXYZ(float x, float y, float z)
{
    std::cout << "moveTo " << x << " " << y << " " << z;
    std::cin.get();
}

void joint_1(float value)
{
    std::cout << "joint_1 " << value;
    std::cin.get();
}

void joint_2(float value)
{
    std::cout << "joint_2 " << value;
    std::cin.get();
}

void joint_3(float value)
{
    std::cout << "joint_3 " << value;
    std::cin.get();
}

void joint_4(float value)
{
    std::cout << "joint_4 " << value;
    std::cin.get();
}

void joint_5(float value)
{
    std::cout << "joint_5 " << value;
    std::cin.get();
}

void joint_6(float value)
{
    std::cout << "joint_6 " << value;
    std::cin.get();
}

void setSpeed(float value)
{
    std::cout << "setSpeed " << value;
    std::cin.get();
}

void delay(float value)
{
    std::cout << "delay " << value;
    std::cin.get();
}

void grab()
{
    std::cout << "grab";
    std::cin.get();
}

void ungrab()
{
    std::cout << "ungrab";
    std::cin.get();
}

void pompUp()
{
    std::cout << "pompUp";
    std::cin.get();
}

void pompOut()
{
    std::cout << "pompOut";
    std::cin.get();
}

void enableLaser()
{
    std::cout << "enableLaser";
    std::cin.get();
}

void disableLaser()
{
    std::cout << "disableLaser";
    std::cin.get();
}

void setDevice(int value)
{
    std::cout << "setDevice " << value;
    std::cin.get();
}

void setConveyorSpeed(int value)
{
    std::cout << "setConveyorSpeed " << value;
    std::cin.get();
}

void setConveyorDir(bool value)
{
    std::cout << "setConveyorDir " << value;
    std::cin.get();
}

void pwm(int pin, int value)
{
    std::cout << "PWM ";
    //if (pin < 10) std::cout << 0;
    std::cout << pin << " " << value << std::endl;
};

