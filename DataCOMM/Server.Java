/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * The server program for the factorial demonstration.
 * @author MadelineGerbitz
 */

import java.io.*;
import java.net.*;

public class Server
{
    Socket socket;
    PrintWriter writer;
    BufferedReader reader;
    
    public static void main(String[] args)
    {
        Server server = new Server();
        server.run();
    }
    
    public void run()
    {
        try
        {
            int portNum = 1025;
            ServerSocket servSock = new ServerSocket(portNum);
            while(true)
            {
                socket = servSock.accept();
                ServerThread servThread = new ServerThread(socket);
                servThread.start();
            }
        }
        catch(Exception e)
        {
            System.out.println("Error: " + e + "\n");
        }
    }
}
