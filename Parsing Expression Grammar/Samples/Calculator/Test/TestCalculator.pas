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

unit TestCalculator;

interface

uses
  TestFramework,
  Calc;

type
  TestCalc = class(TTestCase)
  strict private
    FCalc: ICalc;
  protected
    procedure SetUp; override;
  published
    procedure TestAddAndSubtraction;
    procedure TestMultiplicationAndDivision;
    procedure TestParenthesizedExpressions;
    procedure TestNegateExpression;
    procedure TestFloatingPointNumbers;
    procedure TestGeneral;
  end;

implementation

{ TestCalc }

procedure TestCalc.SetUp;
begin
  inherited;
  FCalc := TCalc.Create;
end;

procedure TestCalc.TestAddAndSubtraction;
begin
  CheckEquals(11+22, FCalc.Evaluate('11+22'));
  CheckEquals(11-22, FCalc.Evaluate('11-22'));
  CheckEquals(1-2+3-4+5-6+7, FCalc.Evaluate('1-2+3-4+5-6+7'));
  CheckEquals(11 + 22, FCalc.Evaluate('11 + 22'));
  CheckEquals(11 + 22, FCalc.Evaluate(' 11 + 22'));
  CheckEquals(11 + 22 , FCalc.Evaluate('11 + 22 '));
  CheckEquals(11 + 22 , FCalc.Evaluate(' 11 + 22 '));
  CheckEquals(11   +    22   , FCalc.Evaluate(' 11   +    22   '));
end;

procedure TestCalc.TestFloatingPointNumbers;
begin
  CheckEquals(3.14 * 1.142857 + (1.41 + 4.3333),
              FCalc.Evaluate('3.14 * 1.142857 + (1.41 + 4.3333)'))
              ;
end;

procedure TestCalc.TestGeneral;
begin
  CheckEquals(5 - 8 * (123 - 545) / 4 + 34 * 22 + 2,
              FCalc.Evaluate('5 - 8 * (123 - 545) / 4 + 34 * 22 + 2'));
end;

procedure TestCalc.TestMultiplicationAndDivision;
begin
  CheckEquals(3.14 * 2, FCalc.Evaluate('3.14 * 2'));
  CheckEquals(2*5, FCalc.Evaluate('2*5'));
  CheckEquals(18/2, FCalc.Evaluate('18/2'));
end;

procedure TestCalc.TestNegateExpression;
begin
  CheckEquals(-4 * 2, FCalc.Evaluate('-4 * 2'));
end;

procedure TestCalc.TestParenthesizedExpressions;
begin
  CheckEquals(6 * (2 + 4) / 2, FCalc.Evaluate('6 * (2 + 4) / 2'));
end;

initialization
  RegisterTest('HSharp.PEG.Samples.Calc', TestCalc.Suite);

end.
