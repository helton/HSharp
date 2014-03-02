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

unit TestHSharp_ORM;

interface

uses
  TestFramework,
  Tests.Entities;

type
  TestMappingAttribute = class(TTestCase)
  published
    procedure Test_Mapping;
  end;

implementation

uses
  System.Rtti,
  System.SysUtils;

{ TestMappingAttributes }

procedure TestMappingAttribute.Test_Mapping;
begin
  {}
end;

initialization
  RegisterTest('HSharp.Mappings.Attributes', TestMappingAttribute.Suite);

end.

