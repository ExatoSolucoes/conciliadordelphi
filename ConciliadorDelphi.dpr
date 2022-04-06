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

  // informações de acesso ao serviço (fornecidas pela Exato Soluções)
  URLWS := 'endereço do webservice';
  USWS := 'usuário de acesso';
  CHWS := 'chave de 32 caracteres';
  CLCONC := 'identificador do cliente';

  // iniciando
  WriteLn('inciando a chamada ao conciliador, carregando requisicao.json');

  // criando o conciliador
  conc := ConciliadorExato.Create(URLWS, USWS);

  // recuperando o texto da requisição
  texto := TFile.ReadAllText('requisicao.json');

  // requisitando a conciliação
  resp := conc.requisitar(texto, CHWS, CLCONC, 'v', 'json');

  // caso a conciliação tenha sucesso, a resposta vem registrada na variável resp.evt[0]
  if ((resp.e = 0) and (Length(resp.evt) > 0)) then
  begin
    jsonO := TJSonObject.Create;
    json := jsonO.ParseJSONValue(resp.evt[0]);
    if (((json as TJSONObject).Get('nome') <> nil) and ((json as TJSONObject).Get('arq') <> nil)) then
    begin
      TFile.WriteAllText((json as TJSONObject).Get('nome').JsonValue.Value, (json as TJSONObject).Get('arq').JsonValue.Value);
      WriteLn('o arquivo "' + (json as TJSONObject).Get('nome').JsonValue.Value + '", trazendo a resposta da conciliação, foi gravado');
    end;
  end;

  // finalizando
  WriteLn('conciliação finalizada com o erro ' + IntToStr(resp.e) + ' (' + resp.msg +')');

  // exibindo o log da operação
  WriteLn('');
  WriteLn('LOG DA REQUISIÇÃO');
  log := conc.recLog;
  for i := 0 to (Length(log)-1) do WriteLn(log[i]);

  // interrompendo a execução
  ReadLn;

end.
