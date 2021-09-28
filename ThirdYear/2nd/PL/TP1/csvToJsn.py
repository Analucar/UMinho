import sys
import re

f = open("file.json","w+")
f.write("[\n")

csv = open("/home/luisa/Desktop/PL/TP1/TP1-Teste7.csv")
first_line = csv.readline() #ler a primeira linha do ficheiro csv

header = re.split(r';',first_line) #separar a primeira linha no ;

indiceList = [] #guardar os indices das colunas que tem listas
option = [] #função de agregação sobre as lista

for i in range(len(header)): #verificar se há listas
    r = re.search(r'\*',header[i])
    if r:
        indiceList.append(i)

for i in indiceList:
    lista = re.split(r'\*',header[i])
    op = re.sub(r'\n',r'',lista[-1]) #capturar tudo exceto o \n
    option.append(op)

CSVFile = csv.readlines()
CSVLen = len(CSVFile)

#processar uma linha de cada vez
for c,linha in enumerate(CSVFile): 
    res = re.split(r';',linha)

    f.write("\t {\n")

    for i in range(len(res)):

        if i in indiceList: #se aquele indice é uma lista
            listStr = re.findall(r'(\d+)',res[i])

            listNr = [int(nr) for nr in listStr] #converter lista de string para int
                
            ind = indiceList.index(i)
            if len(listStr) != 0:

                if option[ind] == "sum":
                    value = sum(listNr)
                elif option[ind] == "avg":
                    value = sum(listNr) / len(listNr)
                elif option[ind] == "min":
                    value = min(listNr)
                elif option[ind] == "max":
                    value = max(listNr)
                else:
                    value = listNr

                s = '\t\t"' + lista[0] + '": ' + str(value)
            else:
                res[i] = re.sub(r'[()]',r'',res[i])
                auxStr = re.split(r',',res[i])
                auxStr = re.sub(r'\'',r'\"',str(auxStr))
     
                s = '\t\t"' + lista[0] + '": ' + auxStr

        else: # caso nao seja lista
            header[i] = re.sub(r'\n',r'',header[i])
            res[i] = re.sub(r'\n',r'',res[i]) #sub para remover \n
            s = '\t\t"' + header[i] + '": "' + res[i] + '"' 

        if i != len(res) - 1:
            s = s + ', '

        f.write(s + '\n')
 
    f.write("\t },\n") if c != CSVLen - 1 else f.write("\t }\n")
        

f.write("]\n")
