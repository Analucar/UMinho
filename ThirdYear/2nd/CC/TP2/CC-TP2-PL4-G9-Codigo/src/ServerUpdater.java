import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;

public class ServerUpdater implements Runnable {
    // private ServerSocket serverSock;
    DatagramSocket conection;
    private Map<Integer, Map<InetAddress, Boolean>> fastFileServers;

    public ServerUpdater(DatagramSocket conection, Map<Integer, Map<InetAddress, Boolean>> fastFileServers) {
        this.conection = conection;
        this.fastFileServers = fastFileServers;
    }

    public void run() {
        System.out.println("---------------------- SERVER _ UPDATER --------------------");
        try {
            run2();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private void run2() throws IOException {
        //     conection = new DatagramSocket(12345);
        InetAddress address = InetAddress.getLocalHost();
        // System.out.println("HttpGw no endereco: " + address + "\n");
        System.out.println("Procura de servidores");
        // conection.setSoTimeout(5000);
        while (true) {
            byte[] receiveData = new byte[61440];
            DatagramPacket packet = new DatagramPacket(receiveData, receiveData.length);
            //conecão broadcast com os servidor
            conection.receive(packet);
            System.out.println(packet.getAddress());
            Package pacote = new Package(packet.getData());
            //porta do servidor
            String msg = pacote.getData();
            Map<InetAddress, Boolean> info = new HashMap<>();
            info.put(packet.getAddress(), true);
            // associa porta do servidor á disponibilidade deste

            synchronized (fastFileServers) {

                System.out.println("\nBEFORE ------------------------------------------------\n");
                fastFileServers.forEach((k, v) -> System.out.println("\n Porta:" + k + "\nAvailability:" + v));

                fastFileServers.put(Integer.valueOf(msg), info);

                System.out.println("\nAFTER ------------------------------------------------\n");
                fastFileServers.forEach((k, v) -> System.out.println("\n Porta:" + k + "\nAvailability:" + v));
            }
            //fastFileServers.put(Integer.valueOf(msg),true);
            System.out.println("---------------------- SERVER _ UPDATER --------------------");
            System.out.println("Servidor encontrado na porta " + msg);
        }

    }

}