import java.io.IOException;
import java.net.*;

public class Transmitter {
    private int port;
    private InetAddress address;
    private DatagramSocket datagramSocket;

    public Transmitter(int port, InetAddress address) throws SocketException {
        this.port = port;
        this.address = address;
        this.datagramSocket = new DatagramSocket();
    }

    public int getPort() {
        return port;
    }

    /*Recebe uma requesta (para já apenas o nome do ficheiro) e comunica-a ao reciever*/
    public void transmitPackage(String request, int i, int id, int offset) throws IOException  {

        byte[] sendRequest = request.getBytes();
        Package pacote;

        if(i == 1) {
            pacote = new Package(false, false, 0, id, offset, sendRequest);
        }else{
            pacote = new Package(false, true, 0, id,  offset, sendRequest);
        }
        byte[] sendData = pacote.serializePackage();

        DatagramPacket sendpacket = new DatagramPacket(sendData, sendData.length, this.address, this.port);

        this.datagramSocket.send(sendpacket);

    }

    /*Recebe o pedido do utilizador, gerado pela função transmitPackage*/
    public Package receiverPackage() throws IOException {

        byte[] receiveData = new byte[64000];

        DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);

        Package pacote = null;
        boolean result = false;

        datagramSocket.receive(receivePacket);
        pacote = new Package(receivePacket.getData());

        return pacote;
    }

    public void timeout(int time) throws SocketException {

        datagramSocket.setSoTimeout(time);

    }

    public void creatConnection() {
        datagramSocket.connect(address,port);
    }

    public InetAddress getInetAddress() {
        return datagramSocket.getInetAddress();
    }

    public void setTransmission(Integer value, InetAddress key) {

        this.port = value;
        this.address = key;

    }

}