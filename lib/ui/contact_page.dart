import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

//pagina com interação

class ContactPage extends StatefulWidget {
  final Contact contact;

  //construtor para pegar o contato que eu quero editar
  //as chaves são para colocar o construtor como opcional pois a tela vai ser para criar e editar
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      //se eu não passar um contato para editar ele vai criar um novo
      _editedContact = Contact();
    } else {
      //transformando o contato em um mapa e criando um novo contato, ou seja, duplicando o contato.
      _editedContact = Contact.fromMap(widget.contact.toMap());
      print(_editedContact);
      //se clicar em editar ele já pega as informações do contato e deixa na tela
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          //caso o nome esteja em branco vai aparecer NOVO CONTATO
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              //verificando e salvando as informações
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                //vanigator trabalha como pilha, pop volta para a tela interior
                Navigator.pop(context, _editedContact);
              } else {
                //caso o nome esteja vazio
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        //verificando se tem uma imagem eu não
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage("images/person.png")),
                  ),
                ),
                onTap: () async {
                  ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                // vai servidor para alterar o título na app bar de novo contato para o nome do contato
                // e falar para a tela que houve uma alteração caso o contato resolva sair sem salvar
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                // vai servidor para alterar o título na app bar de novo contato para o nome do contato
                // e falar para a tela que houve uma alteração caso o contato resolva sair sem salvar
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                // vai servidor para alterar o título na app bar de novo contato para o nome do contato
                // e falar para a tela que houve uma alteração caso o contato resolva sair sem salvar
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deseja descartar as alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    //caso eu cancele ele vai voltar para a tela para continuar editando
                    //lembrando que o POP trabalha com pilhas
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    //dando o pop duas vezes voltaremos para a rela inicial
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      //para sair ou não automaticamente da tela
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
