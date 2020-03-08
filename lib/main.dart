import "package:flutter/material.dart";
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

void main(){
  runApp(MaterialApp(
    home: Home(
      title: "Vida de Horista"
    ),
  ));
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Color _defaultTextColor = Colors.orange[700];
  Color _labelTextColor = Colors.grey;
  double _valueFontSize = 20.0;

  String _salario = "";
  List _salarioDetalhamento = new List(9);
  String _detailButton = "";
  int _selectedYear = getAnoAtual();
  String _selectedMonth = getMesAtual();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _valorHoraController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.'); 
  TextEditingController _horasController = TextEditingController(text: "0");
  TextEditingController _minutosController = TextEditingController(text: "0");
  TextEditingController _feriadosController = TextEditingController(text: "0");

  void _calcular() {   
    setState(() {
      double valorHora = currencyToDouble(_valorHoraController.text, ",", ".");
      double horasTrabalhadas = convertTimeToDouble(_horasController.text + ":" + _minutosController.text);
      int qtdDomFer = getNumberSundays(_selectedYear, _selectedMonth) + int.parse(_feriadosController.text);
      int qtdDiasUteisSab = getNumberDiasUteisSab(_selectedYear, _selectedMonth, qtdDomFer);

      _salarioDetalhamento = _calcularSalario(valorHora, qtdDomFer, qtdDiasUteisSab, horasTrabalhadas);
      print(_salarioDetalhamento);
      _salario = doubleToCurrency(_salarioDetalhamento[8]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Vida de Horista"),
        backgroundColor: _defaultTextColor,
        centerTitle: true,
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.settings),
        //     onPressed: (){},
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Container(
              //   padding: EdgeInsets.all(20.0),
              //   child: Icon(
              //     Icons.attach_money, 
              //     size: 60.0, 
              //     color: _defaultTextColor
              //   ),
              // ),
              TextFormField(
                controller: _valorHoraController,
                decoration: InputDecoration(
                    labelText: "Valor da Hora",
                    labelStyle: TextStyle(color: _labelTextColor),
                    prefix: Text("R\$ "),
                    //border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true
                ),
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: _valueFontSize),
                validator: (value){
                  if(value.isEmpty){
                    return "teste";
                  }
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                          labelText: "Ano",
                          labelStyle: TextStyle(color: _labelTextColor),
                      ),
                      onChanged: (int newValue) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      },
                      items: <int>[
                        2020, 2021, 2022, 2023, 2024, 2025, 2026
                      ]
                        .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString(), 
                              style: TextStyle(
                                fontSize: _valueFontSize
                              )
                            ),
                          );
                        })
                        .toList(),
                    ),
                  ),
                  Divider(indent: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                          labelText: "Mês",
                          labelStyle: TextStyle(color: _labelTextColor),
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                      },
                      items: <String>['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value, 
                              style: TextStyle(
                                fontSize: _valueFontSize
                              )
                            ),
                          );
                        })
                        .toList(),
                    ),
                  ),
                  Divider(indent: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _feriadosController,
                      decoration: InputDecoration(
                          labelText: "Feriados",
                          labelStyle: TextStyle(color: _labelTextColor),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: _valueFontSize),
                      validator: (value){
                        if(value.isEmpty){
                          return "";
                        }
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getHourTextFormField("Horas", _horasController),
                  _getHourSeparator(),
                  _getHourTextFormField("Minutos", _minutosController),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Container(
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: (){
                      if(_formKey.currentState.validate()){
                        FocusScope.of(context).requestFocus(FocusNode());
                        _calcular();
                      }
                    },
                    child: Text("CALCULAR",
                        style: TextStyle(color: Colors.white, fontSize: 20.0)),
                    color: _defaultTextColor,
                  ),
                ),
              ),
              Text(
                _salario,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: _defaultTextColor),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: Table(
                  border: TableBorder.symmetric(),
                  columnWidths: {
                    0: FractionColumnWidth(.5), 
                    1: FractionColumnWidth(.025), 
                    2: FractionColumnWidth(.5), 
                  },
                  children: [
                    _getDetalhamentoField("Valor Horas Trabalhadas", _salarioDetalhamento[0]),
                    _getDetalhamentoField("DSR", _salarioDetalhamento[1]),
                    _getDetalhamentoField("Salário Bruto", _salarioDetalhamento[2], destaque: true),
                    _getDetalhamentoField("INSS", _salarioDetalhamento[4], porcentagemReferencia: _salarioDetalhamento[3], desconto: true),
                    _getDetalhamentoField("IR", _salarioDetalhamento[7], porcentagemReferencia: _salarioDetalhamento[6], desconto: true),
                    _getDetalhamentoField("Salário Líquido", _salarioDetalhamento[8], destaque: true),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _getHourTextFormField(String label, TextEditingController controller){
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: _labelTextColor),
            //border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: _valueFontSize),
        validator: (value){
          if(value.isEmpty){
            return "teste";
          }
        },
      )
    ); 
  }

  TableRow _getDetalhamentoField(String label, double valor, {double porcentagemReferencia = 0, bool desconto = false, destaque = false}){
    if(valor == null){
      return TableRow(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,        
              children:[
              Text("")
            ]
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,        
              children:[
              Text("")
            ]
          ),
        ]
      );
    }
    else{
      String textoValor = doubleToCurrency(valor);
      if(porcentagemReferencia > 0){
        textoValor += " (" + doubleToCurrency((porcentagemReferencia*100), symbol: "") + " % )";
      }
      Color corValor = Colors.black;
      if(desconto){
          textoValor = "- " + textoValor;
          corValor = Colors.red;
      }
      FontWeight destaqueLinha = FontWeight.normal;
      if(destaque){
        destaqueLinha = FontWeight.bold;
      }
      return TableRow(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,        
              children:[
              Text(
                label, 
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14.0, 
                  color: _defaultTextColor, 
                  fontWeight: destaqueLinha
                )
              )
            ]
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,        
            children:[
            Text(
              textoValor,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14.0, color: corValor, fontWeight: destaqueLinha),
            ),
          ]),
        ]
      );
    }
  }

  Padding _getHourSeparator(){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 20.0
        ),
      ),
    );
  }

  static int getAnoAtual(){
    return DateTime.now().year;
  }

  static String getMesAtual(){
    return getMonthByNumber(DateTime.now().month);
  }

  static String getMonthByNumber(int month){
    switch(month){
      case 1  : return "Janeiro"; break;
      case 2  : return "Fevereiro"; break;
      case 3  : return "Março"; break;
      case 4  : return "Abril"; break;
      case 5  : return "Maio"; break;
      case 6  : return "Junho"; break;
      case 7  : return "Julho"; break;
      case 8  : return "Agosto"; break;
      case 9  : return "Setembro"; break;
      case 10 : return "Outubro"; break;
      case 11 : return "Novembro"; break;
      case 12 : return "Dezembro"; break;
      default : return "";
    }
  }

  static int getNumberByMonth(String month){
    switch(month){
      case "Janeiro"  : return 1; break;
      case "Fevereiro": return 2; break;
      case "Março"    : return 3; break;
      case "Abril"    : return 4; break;
      case "Maio"     : return 5; break;
      case "Junho"    : return 6; break;
      case "Julho"    : return 7; break;
      case "Agosto"   : return 8; break;
      case "Setembro" : return 9; break;
      case "Outubro"  : return 10; break;
      case "Novembro" : return 11; break;
      case "Dezembro" : return 12; break;
      default         : return 0;
    }
  }

  double convertTimeToDouble(String time){
    List<String> parts = time.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    double value = hour + (minute/60);
    return value;
  }

  double currencyToDouble(String value, String decimalSeparator, String thousandSeparator){
    String aux = value.replaceAll(thousandSeparator, "");
    aux = aux.replaceAll(decimalSeparator, ".");
    return double.parse(aux);
  }

  static int getNumberSundays(int ano, String month){
    DateTime day = new DateTime(ano, getNumberByMonth(month), 1);
    int numberDays = getNumberOfDaysMonth(ano, month);
    int numberSundays = 0;
    for(int i = 0; i < numberDays; i++){
      if(day.weekday == 7){
        numberSundays++;
      }
      day = day.add(new Duration(days: 1));
    }
    return numberSundays;
  }

  static int getNumberDiasUteisSab(int ano, String month, int numberDomFer){
    return getNumberOfDaysMonth(ano, month) - numberDomFer;
  }

  static int getNumberOfDaysMonth(int ano, String month){
    final DateTime datetimeMonth = new DateTime(ano, getNumberByMonth(month));
    return int.parse(Utils.lastDayOfMonth(datetimeMonth).day.toString());
  }

  List _calcularSalario(double valorHora, int qtdDomFer, int qtdDiasUteisSab, double horasTrabalhadas){
    // print("valor da hora: " + valorHora.toString());
    // print("dom e feriados: " + qtdDomFer.toString());
    // print("dias uteis e sab: " + qtdDiasUteisSab.toString());
    // print("horas trabalhadas: " + horasTrabalhadas.toString());

    var salarioDetalhamento = new List(9);
    double salario = 0.0;
    salario = horasTrabalhadas * valorHora;
    salarioDetalhamento[0] = salario; //VALOR HORAS TRABALHADAS
    //print("salario: " + salario.toString());

    double dsr = (salario/qtdDiasUteisSab) * qtdDomFer;
    salarioDetalhamento[1] = dsr; //VALOR DSR
    //print("dsr: " + dsr.toString());

    double totalBruto = salario + dsr;
    salarioDetalhamento[2] = totalBruto; //% SALÁRIO BRUTO
    //print("total bruto: " + totalBruto.toString());

    double deltaInss = getDeltaInss(totalBruto);
    //print("% inss: " + deltaInss.toString());
    double valorInss = totalBruto * deltaInss;
    salarioDetalhamento[3] = deltaInss; //% INSS
    salarioDetalhamento[4] = valorInss; //VALOR INSS
    //print("valor inss: " + valorInss.toString());

    double baseCalculo = totalBruto - valorInss;
    salarioDetalhamento[5] = baseCalculo; //BASE DE CÁLCULO (SALÁRIO BRUTO - INSS)
    //print("base de calculo: " + baseCalculo.toString());

    double deltaIr = getDeltaIr(baseCalculo);
    salarioDetalhamento[6] = deltaIr; //% IR
    //print("delta imposto de renda: " + deltaIr.toString());

    double parcelaDeduzirIr = getValorIr(deltaIr);
    //print("parcela a deduzir do IR: " + parcelaDeduzirIr.toString());

    double valorIr = (baseCalculo * deltaIr) - parcelaDeduzirIr;
    salarioDetalhamento[7] = valorIr; //VALOR IR
    //print("valor ir: " + valorIr.toString());

    salario = baseCalculo - valorIr;
    salarioDetalhamento[8] = salario; //SALÁRIO LÍQUIDO
    //print("total liquido: " + salario.toString());

    return salarioDetalhamento;

  }

  double getDeltaInss(double valor){
    if(valor <= 1751.81){
      return 0.08;
    }
    else if(valor >= 1751.82 && valor <= 2919.72){
      return 0.09;
    }
    else{ //valor >= 2919.73 && valor <= 5839.45
      return 0.11;
    }
  }

  double getDeltaIr(double baseCalculo){
    if(baseCalculo <= 1903.98){
      return 0;
    }
    else if(baseCalculo >= 1903.99 && baseCalculo <= 2826.65){
      return 0.075;
    }
    else if(baseCalculo >= 2826.66 && baseCalculo <= 3751.05){
      return 0.15;
    }
    else if(baseCalculo >= 3751.06 && baseCalculo <= 4664.68){
      return 0.225;
    }
    else{
      return 0.275;
    }
  }

  double getValorIr(double deltaIr){
    if(deltaIr == 0.075){
      return 142.80;
    }
    else if(deltaIr == 0.15){
      return 354.80;
    }
    else if(deltaIr == 0.225){
      return 636.13;
    }
    else if(deltaIr == 0.275){
      return 869.36;
    }
    else{
      return 0;
    }
  }

  String doubleToCurrency(double value, {symbol: "R\$"}){
    FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
      amount: value,
      settings: MoneyFormatterSettings(
          symbol: symbol,
          thousandSeparator: '.',
          decimalSeparator: ',',
          fractionDigits: 2,
      )
    );
    return fmf.output.symbolOnLeft;
  }

}
