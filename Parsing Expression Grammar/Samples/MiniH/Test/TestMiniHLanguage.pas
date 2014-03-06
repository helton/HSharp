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
  end;

implementation

uses
  HSharp.Core.Lazy;

var
  MiniH: Lazy<IMiniH, TMiniH>;

{ TestMiniH }

procedure TestMiniH.Test;
begin
  CheckEquals(3, MiniH.Instance.Execute('1+2').AsExtended);
  CheckEquals(3, MiniH.Instance.Execute('a=1+2').AsExtended);
  CheckEquals(3, MiniH.Instance.Execute('a').AsExtended);
  CheckEquals(6, MiniH.Instance.Execute('b=2*a').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('d=c=b+a').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('c').AsExtended);
  CheckEquals(9, MiniH.Instance.Execute('d').AsExtended);
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

initialization
  RegisterTest('HSharp.PEG.Samples.MiniH', TestMiniH.Suite);

end.
