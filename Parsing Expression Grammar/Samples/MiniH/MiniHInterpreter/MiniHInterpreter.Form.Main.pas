unit MiniHInterpreter.Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Layouts, FMX.ListBox, FMX.Memo, FMX.TabControl;

type
  TFormInterpreter = class(TForm)
    StyleBook1: TStyleBook;
    tcInterpreter: TTabControl;
    tiCommand: TTabItem;
    tiAST: TTabItem;
    mmAST: TMemo;
    mmCommand: TMemo;
    mmHistory: TMemo;
    procedure FormActivate(Sender: TObject);
    procedure mmCommandKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    CommandCount: Integer;
    procedure ExecuteCommand;
  public
    { Public declarations }
  end;

var
  FormInterpreter: TFormInterpreter;

implementation

uses
  System.Rtti,
  System.StrUtils,
  Language.MiniH,
  HSharp.Core.Lazy,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Node.Visitors,
  HSharp.PEG.Utils;

var
  MiniH: Lazy<IMiniH, TMiniH>;

{$R *.fmx}

procedure TFormInterpreter.ExecuteCommand;
const
  iSeparatorSize = 70;
var
  Value: TValue;
  Tree: INode;
  ResulText: string;
begin
  Inc(CommandCount);
  mmHistory.Lines.Add(Format('[%d]>> %s', [CommandCount, mmCommand.Text.Trim]));
  Tree := MiniH.Instance.Parse(mmCommand.Text);
  mmAST.Text := NodeToStr(Tree);
  try
    Value := MiniH.Instance.Visit(Tree);
  except
    on E: Exception do
      ResulText := '<Exception>: ' + E.Message;
  end;
  mmHistory.Lines.Add(StringOfChar('-', iSeparatorSize));
  if Value.IsEmpty then
    ResulText := 'nil'
  else
    ResulText := Value.AsExtended.ToString;
  mmHistory.Lines.Add(ResulText);
  mmHistory.Lines.Add(StringOfChar('=', iSeparatorSize));
  mmHistory.GoToTextEnd;
  mmHistory.GoToLineBegin;
  mmCommand.Text := '';
  mmCommand.GoToTextEnd;
  mmHistory.GoToLineBegin;
  mmCommand.SetFocus;
end;

procedure TFormInterpreter.FormActivate(Sender: TObject);
begin
  mmCommand.SetFocus;
  tcInterpreter.ActiveTab := tiCommand;
end;

procedure TFormInterpreter.FormCreate(Sender: TObject);
begin
  CommandCount := 0;
end;

procedure TFormInterpreter.mmCommandKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = vkReturn) then
    ExecuteCommand;
end;

end.
