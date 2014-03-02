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

unit HSharp.PEG.Context;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections,
  HSharp.PEG.Context.Interfaces;

type
  TContext = class(TInterfacedObject, IContext)
  strict private
    FText: string;
    FIndex: Integer;
    FState: IStack<Integer>;
  private
    function GetText: string;
    function GetIndex: Integer;
  public
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    constructor Create(const aText: String); reintroduce;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils;

{ TContext }

constructor TContext.Create(const aText: String);
begin
  inherited Create;
  FText  := aText;
  FState := Collections.CreateStack<Integer>;
end;

function TContext.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TContext.GetText: string;
begin
  Result := RightStr(FText, Length(FText) - FIndex);
end;

procedure TContext.IncIndex(aOffset: Integer);
begin
  Inc(FIndex, aOffset);
end;

procedure TContext.RestoreState;
begin
  FIndex := FState.Pop;
end;

procedure TContext.SaveState;
begin
  FState.Push(FIndex);
end;

end.
