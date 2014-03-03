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

unit HSharp.PEG.Rule;

interface

uses
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  TRule = class(TInterfacedObject, IRule)
  strict private
    FName: string;
    FExpression: IExpression;
  strict protected
    function GetName: string;
    function GetExpression: IExpression;
    procedure SetExpression(const aExpression: IExpression);
  public
    function AsString: string;
    function Parse(const aContext: IContext): INode;
    constructor Create(const aName: string; const aExpression: IExpression = nil); reintroduce;
  end;

implementation

{ TRule }

constructor TRule.Create(const aName: string; const aExpression: IExpression);
begin
  inherited Create;
  FName := aName;
  FExpression := aExpression;
  if Assigned(FExpression) then
    FExpression.Name := FName;
end;

function TRule.GetExpression: IExpression;
begin
  Result := FExpression;
end;

function TRule.GetName: string;
begin
  Result := FName;
end;

function TRule.Parse(const aContext: IContext): INode;
begin
  Result := FExpression.Match(aContext);
end;

procedure TRule.SetExpression(const aExpression: IExpression);
begin
  FExpression := aExpression;
  FExpression.Name := FName;
end;

function TRule.AsString: string;
begin
  Result := FName + ' = ' + FExpression.AsString;
end;

end.
