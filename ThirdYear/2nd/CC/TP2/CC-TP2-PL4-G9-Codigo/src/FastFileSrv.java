import java.io.*;
import java.net.*;

public class FastFileSrv {


    public static void main(String[] args) throws InterruptedException, SocketException, UnknownHostException {

        //conecão broadcast para envio da porta especifica

        InetAddress address = InetAddress.getByName(args[0]);
        int port = Integer.parseInt(args[1]);


        DatagramSocket data = new DatagramSocket();
        data.setBroadcast(true);
        data.connect(address, 12345);

        String msg = String.valueOf(port);

        Package p = new Package(false, true, 0, 00000, 0, msg.getBytes());

        byte[] receiveData = p.serializePackage();
        DatagramPacket packet = new DatagramPacket(receiveData, receiveData.length);

        try {
            data.send(packet);
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("Recebendo Pedidos na porta: " + port + "\n");

        Receiver receive = new Receiver(port);

        receive.run();

    }
}


