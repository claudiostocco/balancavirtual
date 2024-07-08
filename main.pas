unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Spin, DataPortSerial, DataPortUART;

type

  { TfmMain }

  TfmMain = class(TForm)
    bbIniciaBalanca: TBitBtn;
    cbParidade: TComboBox;
    cbBParada: TComboBox;
    cbBDados: TComboBox;
    cbVelocidade: TComboBox;
    cbPorta: TComboBox;
    cbMarca: TComboBox;
    dpsCom: TDataPortSerial;
    eDispVirtual: TEdit;
    gbCfg: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    mmCom: TMemo;
    rgResponder: TRadioGroup;
    sePeso: TSpinEdit;
    procedure bbIniciaBalancaClick(Sender: TObject);
    procedure dpsComDataAppear(Sender: TObject);
    procedure dpsComDataAppearUnsafe(Sender: TObject);
    procedure dpsComModemStatus(Sender: TObject);
  private
    function PerguntaSeResponde: Boolean;
  public

  end;

var
  fmMain: TfmMain;

const
  STX = $2;
  ETX = $3;
  ENQ = $5;
  {$ifndef MSWINDOWS}
    SERIAL_NAME = '/dev/ttyS';
  {$else}
    SERIAL_NAME = 'COM';
  {$endif}

implementation

{$R *.lfm}

{ TfmMain }

procedure TfmMain.bbIniciaBalancaClick(Sender: TObject);
begin
  dpsCom.Parity := cbParidade.Text[1];
  dpsCom.StopBits := TSerialStopBits(cbBParada.ItemIndex);
  dpsCom.DataBits := StrToInt(cbBDados.Text);
  dpsCom.BaudRate := StrToInt(cbVelocidade.Text);
  if eDispVirtual.Text = '' then
    dpsCom.Port := SERIAL_NAME+cbPorta.Text
  else
    dpsCom.Port := eDispVirtual.Text+cbPorta.Text;
  dpsCom.Active := True;
  Sleep(150);
  bbIniciaBalanca.Enabled := not dpsCom.Active;
end;

procedure TfmMain.dpsComDataAppear(Sender: TObject);
begin
  mmCom.Lines.Add('dpsComDataAppear -> '+dpsCom.Pull);
end;

procedure TfmMain.dpsComDataAppearUnsafe(Sender: TObject);
var sReceive, sSend: String;
    iPeso: Integer;
begin
  sReceive := dpsCom.Pull;
  mmCom.Lines.Add('Recebeu <- '+sReceive);
  if sReceive.Contains(Chr(ENQ)) then
  begin
    if (rgResponder.ItemIndex = 0) or PerguntaSeResponde then
      iPeso := sePeso.Value
    else
      iPeso := 0;
    case cbMarca.ItemIndex of
      0,2: sSend := Format(Chr(STX)+'%.5d'+Chr(ETX),[iPeso]);
      1: sSend := Format(Chr(STX)+' %.5d %.5d %.5d'+Chr(ETX),[iPeso]);
    end;
    dpsCom.Push(sSend);
    mmCom.Lines.Add('Enviou -> '+sSend);
  end;
end;

procedure TfmMain.dpsComModemStatus(Sender: TObject);
begin
end;

function TfmMain.PerguntaSeResponde: Boolean;
begin
  Result := MessageDlg('Confirma','Responder?',TMsgDlgType.mtConfirmation,mbYesNo,0) = mrYes;
end;

end.

