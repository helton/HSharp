{***************************************************************************}
{                                                                           }
{           HSharp Framework for Delphi                                     }
{                                                                           }
{           Copyright (C) 2014 Helton Carlos de Souza                       }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

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
    tiInterpreter: TTabItem;
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
  ResultText: string;
begin
  Inc(CommandCount);
  mmHistory.Lines.Add(Format('[%.3d]>> %s', [CommandCount, mmCommand.Text.Trim]));
  Tree := MiniH.Instance.Parse(mmCommand.Text);
  mmAST.Text := NodeToStr(Tree);
  try
    try
      Value := MiniH.Instance.Visit(Tree);
      if Value.IsEmpty then
        ResultText := 'null'
      else
        ResultText := Value.AsExtended.ToString;
    except
      on E: Exception do
        ResultText := '<Exception>: ' + E.Message;
    end;
  finally
    mmHistory.Lines.Add(StringOfChar('-', iSeparatorSize));
    mmHistory.Lines.Add(ResultText);
    mmHistory.Lines.Add(StringOfChar('=', iSeparatorSize));
  end;
  mmHistory.GoToTextEnd;
  mmHistory.GoToLineBegin;
  mmCommand.Text := '';
end;

procedure TFormInterpreter.FormActivate(Sender: TObject);
begin
  mmCommand.SetFocus;
  tcInterpreter.ActiveTab := tiInterpreter;
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
