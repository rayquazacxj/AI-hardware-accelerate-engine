import numpy as np
import sys
import matplotlib.pyplot as plt
from PIL import Image
import cv2
import math

W = np.array([[[0, 0, 0], [0, 0.5, 0], [0, 0, -0.5]], 
             [[-0.125, -0.125, -0.125], [-0.125, 1, -0.125], [-0.125, -0.125, -0.125]],
             [[0.0625,  0.125, 0.0625], [ 0.125, 0.25, 0.125], [0.0625,  0.125, 0.0625]]], dtype = 'float16')

precision = 9
#From Francisco Trucco: https://stackoverflow.com/questions/43358620/get-the-hex-of-2s-complement-for-negative-numbers/43359123
def int2hex(number, bits):
    """ Return the 2'complement hexadecimal representation of a number """
    if number < 0:
        return hex((1 << bits) + number)
    else:
        return hex(number)


def WriteToFile(fN, data):
    #Generate testdata
    with open(fN, 'wb') as f:

        for i in xrange(data.shape[0]):
            for j in xrange(data.shape[1]):
                line = (int2hex(data[i][j], precision)[2:]).strip('L')
                
                while(len(line)!=10):
                	line = line + ' '
                line = line + '     //Pixel %03d: %3d'%(i*data.shape[0]+j, data[i][j]) + '\n'
                f.write(line)


def IPF(inPath):
    K = 3 #kernel_size

    img = cv2.imread(inPath, 0)
    in_img = np.array(img)
    
    out_row = (in_img.shape[0] - K) + 1 #Sride = 1, Pad = 0
    out_col = (in_img.shape[1] - K) + 1

    for mode in range(W.shape[0]):
        out_img = np.zeros((in_img.shape)).astype('int16')
        for rows in range(out_row):
    	    for cols in range(out_col):
                out_img[rows+1, cols+1] = np.sum((W[mode][:, :] * in_img[rows:rows+K, cols:cols+K]).astype(int))
                
        WriteToFile('golden%d.dat'%(mode), out_img)
        plt.imsave('golden%d.png'%(mode), out_img, format="png", cmap="gray")
    
    WriteToFile('pattern.dat', in_img)
    
def RIPF(inPath):
    for mode in range(W.shape[0]):
        ptr = 0
        num_lines = sum(1 for line in open(inPath + '%d.dat'%(mode)))
        size = (int)(math.sqrt(num_lines))
        
        out_img = np.zeros((size, size)).astype('int16')
        for line in open(inPath + '%d.dat'%(mode), 'r'):

            i = ptr / size
            j = ptr % size

            val = int(line.split()[0], 16)
            if(val >= 2**(precision-1)):
            	val = val - 2**precision

            out_img[i, j] = val
            ptr = ptr + 1
            
        plt.imsave('reconstruct%d.png'%(mode), out_img, format="png", cmap="gray")
    

def main():
    
    cmd     = (int)(sys.argv[1])
    inPath  = (sys.argv[2])

    if(cmd == 0):
        IPF(inPath)
    else:
    	RIPF(inPath)


if __name__ == "__main__":
    main()