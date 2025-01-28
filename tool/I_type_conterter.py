i_code = str(input("I-type code:"))




print("imm[12]: " + i_code[0:12] + ", HEX=" + str(hex(int(i_code[0:12], 2))[2:].upper()))
print("RT[5]  : " + i_code[12:17] + ", HEX=" + str(hex(int(i_code[12:17], 2))[2:].upper()))
print("funct3[3]: " + i_code[17:20] + ", HEX=" + str(hex(int(i_code[17:20], 2))[2:].upper()))
print("rd[5]: " + i_code[20:25] + ", HEX=" + str(hex(int(i_code[20:25], 2))[2:].upper()))
print("opcode[7]: " + i_code[25:32] + ", HEX=" + str(hex(int(i_code[25:32], 2))[2:].upper()))


#00000000000100000000010010010011