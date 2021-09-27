import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GwWorker implements Runnable {

    private Transmitter send;
    private Socket sock;
    private InetAddress address;
    private Map<Integer, Package[]> pedidos;
    private Map<Integer, Map<InetAddress, Boolean>> fastFileServers;

    public GwWorker(Socket sock, Map<Integer, Package[]> pedidos, Map<Integer, Map<InetAddress, Boolean>> fastFileServers) {
        this.pedidos = pedidos;
        this.sock = sock;
        this.fastFileServers = fastFileServers;
    }

    public void run() {
        Map<InetAddress, Integer> result = null;

        synchronized (fastFileServers) {

            result = getServerLivre();
            //boolean valido = sendACKValido(result);
        }


        for (Map.Entry<InetAddress, Integer> tuplo : result.entrySet()) {
            //conecção com os fast file servers
            try {
                send = new Transmitter(tuplo.getValue(), tuplo.getKey());
            } catch (SocketException e) {
                System.out.println("ERRO TRANSMITTER");
            }
            address = tuplo.getKey();

        }

        send.creatConnection();

        InputStream sis = null;
        String request = null;
        BufferedReader br = null;
        try {
            sis = sock.getInputStream();
            br = new BufferedReader(new InputStreamReader(sis));
            request = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        while (true) {

            try {
                System.out.println(request + "\n");
                String[] requestParam = request.split(" ");
                String path = requestParam[1];
                String[] realPath = path.split("/");
                //System.out.println(realPath[1] + "\n");

                int max = 5000;
                int min = 1000;
                int range = max - min + 1;

                int idPacket = (int) (Math.random() * range) + min;

                //envio do pedido para os servidores
                send.transmitPackage(realPath[1], 1, idPacket, 0);

                int totalLength = 60000;

                // receber informação

                Package conteudo = null;
                int tam, idPedido, falta;
                tam = 0;
                idPedido = 0;
                int flag = 0;
                int offset = 0;

                // ao fim do timeout voltamos a pedir o ficheiro...pode-se implementar contador

                send.timeout(1000);
                while (true) {
                    try {
                        conteudo = send.receiverPackage();
                        offset = conteudo.getOffset();
                        falta = conteudo.getResto();
                        idPedido = conteudo.getIdPackage();
                        tam = falta + 1 + (offset / totalLength);
                        break;
                    } catch (SocketTimeoutException e) {
                        send.transmitPackage("RENVIO", 1, idPacket, 0);
                    } catch (PortUnreachableException s) {
                        System.out.println("PERDA DE CONECÇÃO");
                        throw new Exception();
                    }
                }

                Package[] pacotes = new Package[tam];

                for (int a = 0; a < tam; a++) {
                    pacotes[a] = null;
                }

                int indice = offset / totalLength;

                pacotes[indice] = conteudo;

                boolean fragmentado = conteudo.isFragmentado();
                int count = 0;

                while (fragmentado && ((offset / totalLength) + 1 != tam - 1) && count != 5) {
                    send.timeout(1000);
                    while (true) {
                        try {
                            conteudo = send.receiverPackage();
                            offset = conteudo.getOffset();
                            falta = conteudo.getResto();
                            idPedido = conteudo.getIdPackage();
                            pacotes[(offset / totalLength)] = conteudo;
                            count=0;
                            break;
                        } catch (SocketTimeoutException e) {
                            count++;
                            break;
                        }
                    }
                    fragmentado = conteudo.isFragmentado();
                    //System.out.println(send.isClose());
                }

                int a = 0;
                int RETRIES = 0;
                while (a < pacotes.length) {

                    if (pacotes[a] == null) {
                        String res = "RENVIO";
                        send.transmitPackage(res, 1, idPedido, offset+totalLength);
                        send.timeout(1000);
                        while (true) {
                            try {
                                conteudo = send.receiverPackage();
                                offset = conteudo.getOffset();
                                falta = conteudo.getResto();
                                idPedido = conteudo.getIdPackage();
                                pacotes[(offset / totalLength)] = conteudo;
                                break;
                            } catch (SocketTimeoutException e) {
                                send.transmitPackage(res, 1, idPedido, offset+totalLength);
                            } catch (PortUnreachableException s) {
                                System.out.println("PERDA DE CONECÇÃO");
                                throw new Exception();
                            }
                        }

                        RETRIES++;

                    } else {
                        a++;
                    }
                }

                List<Byte> content = new ArrayList<>();
                send.transmitPackage("ACK", 2, idPedido, 0);
                pedidos.put(idPedido, pacotes);


                send.timeout(1000);
                while (true) {
                    try {
                        conteudo = send.receiverPackage();
                        if (!conteudo.getData().equals("LIVRE")) {
                            throw new SocketTimeoutException();
                        } else {
                            int porta = conteudo.getIdPackage();
                            InetAddress add = send.getInetAddress();

                            Map<InetAddress, Boolean> info = new HashMap<>();
                            info.put(add, true);
                            System.out.println("\nBEFORE ------------------------------------------------\n");
                            fastFileServers.forEach((k, v) -> System.out.println("\n Porta:" + k + "\nAvailability:" + v));
                            fastFileServers.put(porta, info);
                            System.out.println("\nAFTER ------------------------------------------------\n");
                            fastFileServers.forEach((k, v) -> System.out.println("\n Porta:" + k + "\nAvailability:" + v));
                            send.transmitPackage("ACK LIVRE", 2, 9999, 0);
                            break;
                        }
                    } catch (SocketTimeoutException e) {
                        send.transmitPackage("REENVIO LIVRE", 1, 9999, 0);
                    } catch (PortUnreachableException s) {
                        System.out.println("PERDA DE CONECÇÃO");
                        throw new Exception();
                    }
                }

                // envio dos bytes para o cliente http

                //System.out.println("FIM DE TRANSMIÇÃO");

                for (int b = 0; b < pacotes.length; b++) {

                    byte[] data = pacotes[b].getDataBytes();

                    for (int i = 0; i < data.length; i++) {
                        content.add(data[i]);
                    }
                }

                Byte[] bytes = content.toArray(new Byte[content.size()]);
                byte[] res = new byte[bytes.length];

                int j = 0;
                // Unboxing Byte values. (Byte[] to byte[])
                for (Byte b : bytes) {
                    res[j++] = b;
                }

                DataOutputStream out2 = new DataOutputStream(sock.getOutputStream());

                out2.write(res);
                out2.flush();

                br.close();
                out2.close();

                System.out.println("FIM TRANSMICAO: " + realPath[1] + "\n");
                break;


            } catch (Exception e) {
                //send.disconected();

                //* desnecessário
                changeState(send.getPort());
                Map<InetAddress, Integer> res = null;

                while (res == null) {
                    synchronized (fastFileServers) {

                        res = getServerLivre();
                    }
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException interruptedException) {
                        interruptedException.printStackTrace();
                    }
                }

                for (Map.Entry<InetAddress, Integer> tuplo : res.entrySet()) {
                    //conecção com os fast file servers
                    send.setTransmission(tuplo.getValue(), tuplo.getKey());
                    address = tuplo.getKey();

                }
                send.creatConnection();
            }
        }
    }

    private void changeState(Integer port) {

        Map<InetAddress, Boolean> res = fastFileServers.get(port);

        for (Map.Entry<InetAddress, Boolean> cont : res.entrySet()) {

            cont.setValue(false);
        }
    }

    private Map<InetAddress, Integer> getServerLivre() {

        Map<InetAddress, Integer> res = new HashMap<>();

        for (Map.Entry<Integer, Map<InetAddress, Boolean>> entry : fastFileServers.entrySet()) {

            Map<InetAddress, Boolean> info = entry.getValue();

            for (Map.Entry<InetAddress, Boolean> cont : info.entrySet()) {

                if (cont.getValue()) {
                    cont.setValue(false);
                    res.put(cont.getKey(), entry.getKey());
                    return res;
                }
            }
        }
        return null;
    }
}
