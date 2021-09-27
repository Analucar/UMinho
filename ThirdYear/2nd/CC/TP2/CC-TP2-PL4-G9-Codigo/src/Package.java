import java.io.*;

public class Package {
    private boolean fragmentado;
    private boolean ack;
    private int resto;
    private int idPackage;
    private int offset;
    private byte[] data;

    public Package(boolean flag, boolean ack, int resto, int idPackage, int offset, byte[] data) {
        this.fragmentado = flag;
        this.ack = ack;
        this.resto = resto;
        this.idPackage = idPackage;
        this.offset = offset;
        this.data = data;
    }

    public Package(byte[] data) throws IOException {

        ByteArrayInputStream in = new ByteArrayInputStream(data);
        ObjectInputStream is = new ObjectInputStream(in);

        this.fragmentado = is.readBoolean();
        this.ack = is.readBoolean();
        this.resto = is.readInt();
        this.idPackage = is.readInt();
        this.offset = is.readInt();

        int tam = is.readInt();

        byte[] dataPacket = new byte[tam];
        is.readFully(dataPacket);
        this.data = dataPacket;

    }

    public byte[] serializePackage(){

        byte[] serialize = null;
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream out = new ObjectOutputStream(bos);
            out.writeBoolean(fragmentado);
            out.writeBoolean(ack);
            out.writeInt(resto);
            out.writeInt(idPackage);
            out.writeInt(offset);
            out.writeInt(data.length);
            out.write(data);
            out.flush();
            serialize = bos.toByteArray();
            bos.close();
        }catch (Exception e){e.printStackTrace();}

        return serialize;
    }

    public boolean isFragmentado() {
        return fragmentado;
    }

    public int getIdPackage() {
        return idPackage;
    }

    public int getOffset() {
        return offset;
    }

    public boolean isAck() {
        return ack;
    }

    public int getResto() {
        return resto;
    }

    public String getData(){

        String result = new String(data,0,data.length);
        return result;

    }

    public byte[] getDataBytes() {
        return this.data;
    }
}
