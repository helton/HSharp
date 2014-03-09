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

unit TestMiniHLanguage;

interface

uses
  TestFramework,
  Language.MiniH;

type
  TestMiniH = class(TTestCase)
  published
    procedure Test;
    procedure TestMultipleStatements;
    procedure TestIf;
    procedure TestWhile;
    procedure TestFor;
    procedure TestFunctionDefinition;
    procedure TestNestedFunctions;
    procedure TestRecursiveFunctions;
  end;

implementation

uses
  HSharp.Core.Lazy;

var
  MiniH: Lazy<IMiniH, TMiniH>;

{ TestMiniH }

procedure TestMiniH.Test;
begin
  CheckEquals(3, MiniH.Instance.Execute('1 + 2').AsExtended);
  CheckEquals(3, MiniH.Instance.Execute('a = 1 + 2').AsExtended);
  CheckEquals(3, MiniH.Instance.Execute('a').AsExtended);
  CheckEquals(6, MiniH.Instance.Execute('b = 2 * a').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('d = c = b + a').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('c').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('d').AsExtended);
end;

procedure TestMiniH.TestFor;
begin
  CheckEquals(
    10,
    MiniH.Instance.Execute(
      'for i = 1 to 10 do {' + sLineBreak +
      '  x = i'              + sLineBreak +
      '};'                   + sLineBreak +
      'x'
    ).AsExtended
  );
end;

procedure TestMiniH.TestFunctionDefinition;
begin
  CheckTrue(MiniH.Instance.Execute('def sum(x, y) { x + y }').IsEmpty);
  CheckEquals(199, MiniH.Instance.Execute('sum(100, 99)').AsExtended);
  MiniH.Instance.Execute(
    'def sum_until(n) {'       + sLineBreak +
    '  i = n;'                 + sLineBreak +
    '  result = 0;'            + sLineBreak +
    '  while i do {'           + sLineBreak +
    '    result = result + i;' + sLineBreak +
    '    i = i - 1;'           + sLineBreak +
    '  };'                     + sLineBreak +
    '  result'                 + sLineBreak +
    '}'
  );
  CheckEquals(55, MiniH.Instance.Execute('sum_until(10)').AsExtended);
  CheckEquals(120, MiniH.Instance.Execute('sum_until(sum_until(5))').AsExtended);
end;

procedure TestMiniH.TestIf;
begin
  CheckEquals(123,  MiniH.Instance.Execute('if 1 then 123').AsExtended);
  CheckTrue(MiniH.Instance.Execute('if 0 then 123').IsEmpty);
  CheckEquals(123, MiniH.Instance.Execute('if  1  then  123  else  999').AsExtended);
  CheckEquals(999, MiniH.Instance.Execute('if  0  then  123  else  999').AsExtended);
end;

procedure TestMiniH.TestMultipleStatements;
begin
  CheckEquals(512, MiniH.Instance.Execute('1 + 2; 7 * 4; 2 - 5; 2^9').AsExtended);
end;

procedure TestMiniH.TestNestedFunctions;
begin
  MiniH.Instance.Execute(
    'def inner_test(x, y) {'     + sLineBreak +
    '  def inner_sum1(a, b) {'   + sLineBreak +
    '    def inner_sum2(c, d) {' + sLineBreak +
    '      c + d;'               + sLineBreak +
    '    };'                     + sLineBreak +
    '    inner_sum2(a, b);'      + sLineBreak +
    '  };'                       + sLineBreak +
    '  inner_sum1(x, y);'        + sLineBreak +
    '};'
  );
  CheckEquals(1099, MiniH.Instance.Execute('inner_test(100, 999)').AsExtended);
end;

procedure TestMiniH.TestRecursiveFunctions;
begin
  CheckEquals(
    120,
    MiniH.Instance.Execute(
      'def factorial(n) {'       + sLineBreak +
      '  if n then'              + sLineBreak +
      '    n * factorial(n - 1)' + sLineBreak +
      '  else'                   + sLineBreak +
      '    1'                    + sLineBreak +
      '};'                       + sLineBreak +
      'factorial(5);'
    ).AsExtended
  );
end;

procedure TestMiniH.TestWhile;
begin
  CheckEquals(
    55,
    MiniH.Instance.Execute(
      'i = 10;'      + sLineBreak +
      'a = 0;'       + sLineBreak +
      'while i do {' + sLineBreak +
      '  a = a + i;' + sLineBreak +
      '  i = i - 1;' + sLineBreak +
      '};'           + sLineBreak +
      'a'
    ).AsExtended
  );
end;

initialization
  RegisterTest('HSharp.PEG.Samples.MiniH', TestMiniH.Suite);

end.
