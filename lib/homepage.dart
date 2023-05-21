import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tag_print/previewpage.dart';
import 'package:tag_print/tagdata.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tag_print/tagdatamain.dart';
import 'package:tag_print/tagfinaldata.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final _formKey = GlobalKey<FormState>();
  final Tagdata _tagdata = Tagdata();
  final Tagdatamain _tagdatamain = Tagdatamain();
  final List<Tagdata> _tagdatalist = [];
  final List<Tagfinaldata> finalTagList = [];

  DateTime currentDate = DateTime.now();
  String? selectedDate;

  static const List<String> numbersList = <String>['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'];

  final String _totalItemsSelectedValue = numbersList.first;
  final String _tagsToPrintSelectedValue = numbersList.first;

  static const List<String> serviceList = <String>['-','D','d/r','D+d/r','D+st','D+S','Dye','Dye/B','Dye/Pb','Dye+D','Dye+D+d/r','c/r','RP'];

  String? _serviceSelectedValue;

  @override
  void initState() {
    super.initState();
    selectedDate = '${currentDate.day}-${currentDate.month}-${currentDate.year}';
    _tagdatamain.totalitem = 1;
    _tagdatamain.collectdate = selectedDate;
    _tagdata.note = '-';
    _tagdata.servicelist = '-';
    _tagdata.tagtoprint = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Tag Details Entry')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever_outlined,
              size: 30.0,
            ),
            onPressed: () {
              _clearAll();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_tagdatalist.isNotEmpty){
            _displayPdf();
          } else {
            return;
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.print),
      ),
    );
  }

  void _displayPdf() {
    final doc = pw.Document();
    const pdfpagesize = PdfPageFormat(50.8 * (72.0/25.4), 25.4 * (72.0/25.4), marginAll: 0);

    finalTagList.clear();

    for(var tagDataf in _tagdatalist){
      for(int i=1; i<=tagDataf.tagtoprint!; i++){
        finalTagList.add(Tagfinaldata(collectdate: _tagdatamain.collectdate, branchname: 'S', receiptno: _tagdatamain.receiptno,
        mobileno: _tagdatamain.mobileno, totalitem: _tagdatamain.totalitem, servicelist: tagDataf.servicelist, note: tagDataf.note));
      }
    }

    for(var tag in finalTagList){

      doc.addPage(
        pw.Page(
          pageFormat: pdfpagesize,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('${tag.branchname}- ${tag.receiptno}', style: pw.TextStyle(lineSpacing:1, fontSize: 14, fontWeight: pw.FontWeight.bold )),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.max,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(),
                            borderRadius: pw.BorderRadius.circular(8)
                          ),
                          child: pw.Text(
                            tag.totalitem.toString(), style: pw.TextStyle(lineSpacing:1, fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                            padding: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2)
                        ),
                        pw.Text(tag.collectdate!, style: const pw.TextStyle(lineSpacing:1, fontSize: 10)),
                      ]
                  ),
                  pw.Text(tag.mobileno.toString(), style: const pw.TextStyle(lineSpacing:1, fontSize: 10)),
                  pw.Text('${tag.servicelist} - ${tag.note}', style: const pw.TextStyle(lineSpacing:1, fontSize: 10)),
                  pw.Text('------------------------------------', style: const pw.TextStyle(lineSpacing:1, fontSize: 8)),
                ],
              )
            );
          },
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: pdfpagesize,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(2, 5, 2, 5)
              )
          );
        },
      ),
    );

    /// open Preview Screen
    Navigator.push(context, MaterialPageRoute(builder:
        (context) => Previewpage(doc: doc),));
  }

  _form() => Container(
    color: Colors.white24,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Collected Date'),
                      TextButton(
                        child: Text(selectedDate!),
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: currentDate,
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2024)
                          );
                          if(newDate==null) return;
                          setState(() {
                            selectedDate = '${newDate.day}-${newDate.month}-${newDate.year}';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4)
                    ],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(label: Center(child: Text('Receipt Number'),),border: OutlineInputBorder()),
                    validator: (val) => (val!.length < 2 ? 'Please Check Once' : null),
                    onSaved: (val) => _tagdatamain.receiptno = int.parse(val!),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Items'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _totalItemsSelectedValue,
                        items: numbersList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value, textAlign: TextAlign.center,)),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _tagdatamain.totalitem = int.parse(value!);
                          });
                        },
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),

          const Divider(
            height: 12
          ),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10)
                    ],
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(label: Center(child: Text('Mobile Number'),),border: OutlineInputBorder()),
                    validator: (val) => (val!.length < 10 ? 'Please check once' : null),
                    onSaved: (val) => _tagdatamain.mobileno = val,
                  ),
                ),
              ),
            ],
          ),

          const Divider(
              height: 12
          ),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tags to Print'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _tagsToPrintSelectedValue,
                        items: numbersList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value, textAlign: TextAlign.center,)),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _tagdata.tagtoprint = int.parse(value!);
                          });
                        },
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10)
                    ],
                    decoration: const InputDecoration(label: Center(child: Text('Note'),),border: OutlineInputBorder()),
                    onSaved: (val) => _tagdata.note = val,
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Services'),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: const Center(child: Text('Choose Service', textAlign: TextAlign.center,)),
                          value: _serviceSelectedValue,
                          items: serviceList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(child: Text(value, textAlign: TextAlign.center,)),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _tagdata.servicelist = value;
                            });
                          },
                        ),
                      ],
                    ),
                  )
              ),

            ],
          ),

          Container(
            margin: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => _onSubmit(),
              child: const Text('Add to List'),
            ),
          ),

        ],
      )
    ),
  );

  void _onSubmit() {
    setState(() {

      var form = _formKey.currentState;
      if (form!.validate()) {
        form.save();
        _tagdatalist.add(Tagdata(tagtoprint: _tagdata.tagtoprint, servicelist: _tagdata.servicelist, note: _tagdata.note));
        //form.reset(); /* remove later */
      }

    });
  }

  void _onDeleteItemPressed(int indexValue) {
    setState(() {
      _tagdatalist.removeAt(indexValue);
    });
  }

  void _clearAll() {
    setState(() {
      var form = _formKey.currentState;
      _tagdatalist.clear();
      finalTagList.clear();
      selectedDate = '${currentDate.day}-${currentDate.month}-${currentDate.year}';
      _tagdatamain.totalitem = 1;
      _tagdatamain.collectdate = selectedDate;
      _tagdata.note = '-';
      _tagdata.servicelist = '-';
      _tagdata.tagtoprint = 1;
      form?.reset();
    });
  }

  _list() => Expanded(
    child: Card(
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.cyan,
                    child: Center(
                      child: Text(
                        _tagdatalist[index].tagtoprint.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(
                    _tagdatalist[index].servicelist.toString(),
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _tagdatalist[index].note.toString(),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () {
                       _onDeleteItemPressed(index);
                    },
                  ),
                  onTap: () {},
                ),
                const Divider(
                  height: 5.0,
                ),
              ],
            );
          },
          itemCount: _tagdatalist.length,
        ),
      ),
    ),
  );
}