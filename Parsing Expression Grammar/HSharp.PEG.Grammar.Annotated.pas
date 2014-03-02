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

unit HSharp.PEG.Grammar.Annotated;

interface

uses
  HSharp.PEG.Rule.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Interfaces;

type
  TAnnotatedGrammar = class(TGrammar)
  strict private
    FGrammarText: string;
  public
    constructor Create(const aRules: array of IRule;
      const aDefaultRule: IRule = nil); override;
    property GrammarText: string read FGrammarText;
  end;

implementation

uses
  System.Rtti,
  HSharp.Core.ArrayString,
  HSharp.Core.Rtti,
  HSharp.PEG.Grammar.Attributes;

{ TAnnotatedGrammar }

constructor TAnnotatedGrammar.Create(const aRules: array of IRule;
  const aDefaultRule: IRule);
var
  Method: TRttiMethod;
  Attribute: TCustomAttribute;
  Grammar: IArrayString;
begin
  inherited;
  Grammar := TArrayString.Create;
  for Method in RttiContext.GetType(ClassType).GetMethods do
  begin
    for Attribute in Method.GetAttributes do
    begin
      if Attribute is RuleAttribute then
        Grammar.Add(RuleAttribute(Attribute).Rule);
    end;
  end;
  FGrammarText := Grammar.AsString;
end;

end.