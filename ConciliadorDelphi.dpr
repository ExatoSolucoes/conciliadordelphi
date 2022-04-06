program ConciliadorDelphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils, System.JSON, ClassWSExato in 'ClassWSExato.pas';

var
  conc : ConciliadorExato;
  resp : WSResposta;
  texto : string;
  log : ClassWSExato.TStringArr;
  URLWS, USWS, CHWS, CLCONC : string;
  i : integer;
  jsonO : TJSonObject;
  json : TJSonValue;

begin

  // informa��es de acesso ao servi�o (fornecidas pela Exato Solu��es)
  URLWS := 'endere�o do webservice';
  USWS := 'usu�rio de acesso';
  CHWS := 'chave de 32 caracteres';
  CLCONC := 'identificador do cliente';

  // iniciando
  WriteLn('inciando a chamada ao conciliador, carregando requisicao.json');

  // criando o conciliador
  conc := ConciliadorExato.Create(URLWS, USWS);

  // recuperando o texto da requisi��o
  texto := TFile.ReadAllText('requisicao.json');

  // requisitando a concilia��o
  resp := conc.requisitar(texto, CHWS, CLCONC, 'v', 'json');

  // caso a concilia��o tenha sucesso, a resposta vem registrada na vari�vel resp.evt[0]
  if ((resp.e = 0) and (Length(resp.evt) > 0)) then
  begin
    jsonO := TJSonObject.Create;
    json := jsonO.ParseJSONValue(resp.evt[0]);
    if (((json as TJSONObject).Get('nome') <> nil) and ((json as TJSONObject).Get('arq') <> nil)) then
    begin
      TFile.WriteAllText((json as TJSONObject).Get('nome').JsonValue.Value, (json as TJSONObject).Get('arq').JsonValue.Value);
      WriteLn('o arquivo "' + (json as TJSONObject).Get('nome').JsonValue.Value + '", trazendo a resposta da concilia��o, foi gravado');
    end;
  end;

  // finalizando
  WriteLn('concilia��o finalizada com o erro ' + IntToStr(resp.e) + ' (' + resp.msg +')');

  // exibindo o log da opera��o
  WriteLn('');
  WriteLn('LOG DA REQUISI��O');
  log := conc.recLog;
  for i := 0 to (Length(log)-1) do WriteLn(log[i]);

  // interrompendo a execu��o
  ReadLn;

end.
