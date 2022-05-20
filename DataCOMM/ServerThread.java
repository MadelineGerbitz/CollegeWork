/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * The server thread program for the factorial demonstration.
 * @author MadelineGerbitz
 */

import java.io.*;
import java.net.*;
import java.io.File;

class ServerThread extends Thread
{
    Socket socket;
    PrintWriter writer;
    BufferedReader reader;
    
    public ServerThread(Socket s)
    {
        try
        {
            socket = s;
            writer = new PrintWriter(socket.getOutputStream(), true);
            reader = new BufferedReader(new InputStreamReader
                                                    (socket.getInputStream()));
        }
        catch(Exception e)
        {
            System.out.println("Error: " + e + "\n");
        }
    }
    public void run()
    {
        try
        {
            boolean quitTime = false;
            System.out.println("A client has connected.\n");
            while(!quitTime)
            {
                quitTime = true;
            }
            socket.close();
        }
        catch(NullPointerException e)
        {
            System.out.println("A client has disconnected.\n");
        }
        catch(Exception e)
        {
            System.out.println("Error: " + e + "\n");
        }
    }
    private String listFiles()
    {
        String list = "";
        File dir = new File("Files");
        File [] files = dir.listFiles();
        for(int i = 0; i < dir.length(); i++)
        {
            if(files[i].isFile())
            {
                list += files[i].getName() + "#";
            }
        }
        return list;
    }
    private void sendFile(String filename)
    {
        try
        {
            
        }
        catch(Exception e)
        {
            System.out.println("Error: " + e + "\n");
        }
    }
    private void getFile(String filename)
    {
        
    }
}
