import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {

    public static void main(String[] args) {

        String[] values = null;
        List<List<String>> records = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader("dataMini.csv"))) {
            String line;
            while ((line = br.readLine()) != null) {
                values = line.split(";");
                records.add(Arrays.asList(values));
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        List<List<String>> nomeAdj = new ArrayList<>();


        for (int i = 0; i < records.size(); i++) {

            List<String> recolha = records.get(i);
            List<String> parsing = new ArrayList<>();

            String ponto = recolha.get(3);
            parsing.add(recolha.get(2));

            if (ponto.contains("->")) {

                String[] idPonto = ponto.split(": ", 2);

                String[] nomePonto = idPonto[1].split(" \\(", 2);
                parsing.add(nomePonto[0]);

                String[] nome1 = nomePonto[1].split(": ");
                String[] nomeProx = nome1[1].split(" - ");
                parsing.add(nomeProx[0]);

                nomeAdj.add(parsing);

            } else {

                String[] idPonto = ponto.split(": ");

                String[] nomePonto = idPonto[1].split(",");
                parsing.add(nomePonto[0]);

                nomeAdj.add(parsing);

            }

        }

        int indice = 0;


        List<String[]> ficheiro = new ArrayList<>();

        for (List<String> linha : nomeAdj) {

            String[] line = new String[9];

            line[0] = records.get(indice).get(0);
            line[1] = records.get(indice).get(1);
            line[2] = linha.get(0);
            line[3] = linha.get(1);

            String adjacentes = "";

            if(linha.size()>2) {

                String prox1 = searchProx(linha.get(2), nomeAdj);

                if (prox1 != null) {
                    adjacentes = adjacentes + prox1 + "/";
                }
            }

            if(indice < records.size()-1){

                String prox2 = nomeAdj.get(indice+1).get(0);
                adjacentes = adjacentes + prox2;
            }

            line[4] = adjacentes;
            line[5] = records.get(indice).get(4);
            line[6] = records.get(indice).get(5);
            line[7] = records.get(indice).get(6);
            line[8] = records.get(indice).get(7);

            ficheiro.add(line);
            indice++;
        }

        File csvOutputFile = new File("newDataMini.csv");
        try (PrintWriter pw = new PrintWriter(csvOutputFile)) {

            for (String[] e : ficheiro) {

                String linha = convertToCSV(e);
                pw.write(linha);
                pw.write("\n");
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static String searchProx(String nome,List<List<String>> records ){

        String id = null;

        for (List<String> linha : records) {

            String name = linha.get(1);

            if(name.compareTo(nome)==0){
                return linha.get(0);
            }
        }
        return id;
    }

    public static String convertToCSV(String[] data) {

        return Stream.of(data)
                .collect(Collectors.joining(";"));
    }
}
