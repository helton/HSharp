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

unit TestHSharp_Core_Version;

interface

uses
  TestFramework,
  HSharp.Core.Version;

type
  TestVersion = class(TTestCase)
  strict private
    Version: TVersion;
  protected
    procedure SetUp; override;
  published
    procedure Clear_ShouldAssignZeroToAllLevels;
    procedure Create_ShouldAssignValuesToVersionRecord;
    procedure ImplicitStringConversionWith1Level_ShouldAssignMajorVersion;
    procedure ImplicitStringConversionWith2Levels_ShouldAssignMajorVersionAndMinorVersion;
    procedure ImplicitStringConversionWith3Levels_ShouldAssignMajorVersion_MinorVersionAndRelease;
    procedure ImplicitStringConversionWith4Levels_ShouldAssignMajorVersion_MinorVersion_ReleaseAndBuild;
    procedure ImplicitStringConversionWith5LevelsOrMore_ShouldRaiseAnException;
    procedure ImplicitStringConversionWithWrongFormat_ShouldRaiseAnException;
    procedure ImplicitStringConversionWithLetters_ShouldRaiseAnException;
    procedure ImplicitStringConversionWithNegativeNumbers_ShouldRaiseAnException;
    procedure ImplicitIntegerConversion_ShouldAssignMajorVersion;
    procedure ImplicitIntegerConversionWithNegativeNumber_ShouldRaiseAnException;
    procedure ImplicitExtendedConversion_ShouldAssignMajorVersionAndMinorVersion;
    procedure ImplicitExtendedConversionWithNegativeNumber_ShouldRaiseAnException;
    procedure EqualOperatorOverloading_ShouldCompareCorrectly;
    procedure NotEqualOperatorOverloading_ShouldCompareCorrectly;
    procedure LessThanOperatorOverloading_ShouldCompareCorrectly;
    procedure LessThanOrEqualOperatorOverloading_ShouldCompareCorrectly;
    procedure GreaterThanOperatorOverloading_ShouldCompareCorrectly;
    procedure GreaterThanOrEqualOperatorOverloading_ShouldCompareCorrectly;
  end;

implementation

uses
  System.Rtti,
  System.SysUtils;

{ TestVersion }

procedure TestVersion.Clear_ShouldAssignZeroToAllLevels;
begin
  Version.MajorVersion := 111;
  Version.MinorVersion := 222;
  Version.Release      := 333;
  Version.Build        := 444;
  Version.Clear;
  CheckEquals(0, Version.MajorVersion, 'Major version was cleared correctly');
  CheckEquals(0, Version.MinorVersion, 'Minor version was cleared  correctly');
  CheckEquals(0, Version.Release, 'Release version was not cleared  correctly');
  CheckEquals(0, Version.Build, 'Build version was not cleared correctly');
end;

procedure TestVersion.Create_ShouldAssignValuesToVersionRecord;
begin
  Version.Clear;
  Version := TVersion.Create(111, 222, 333, 444);
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(222, Version.MinorVersion, 'Minor version was not assigned correctly');
  CheckEquals(333, Version.Release, 'Release version was not assigned correctly');
  CheckEquals(444, Version.Build, 'Build version was not assigned correctly');
end;

procedure TestVersion.EqualOperatorOverloading_ShouldCompareCorrectly;
var
  Version1, Version2: TVersion;
begin
  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckTrue(Version1 = Version2, 'Versions should be equal');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(555, 666, 777, 888);
  CheckFalse(Version1 = Version2, 'Versions should not be equal');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 555);
  CheckFalse(Version1 = Version2, 'Versions should not be equal');

  CheckTrue(TVersion.Create(111, 222, 333, 444) = '111.222.333.444', 'Versions should be equal');
  CheckTrue(TVersion.Create(111, 222) = 111.222, 'Versions should be equal');
end;

procedure TestVersion.GreaterThanOperatorOverloading_ShouldCompareCorrectly;
var
  Version1, Version2: TVersion;
begin
  Version1 := TVersion.Create(111, 222, 333, 555);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckTrue(Version1 > Version2, 'Version1 should be greater than Version2 [1]');

  Version1 := TVersion.Create(111, 222, 444, 444);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckTrue(Version1 > Version2, 'Version1 should be greater than Version2 [2]');

  Version1 := TVersion.Create(111, 333, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckTrue(Version1 > Version2, 'Version1 should be greater than Version2 [3]');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(000, 222, 333, 444);
  CheckTrue(Version1 > Version2, 'Version1 should be greater than Version2 [4]');

  CheckTrue(TVersion.Create(111, 222, 333, 555) > '111.222.333.444', 'Version1 should be greater than Version2 [5]');
  CheckTrue(TVersion.Create(111, 333) > 111.222, 'Version1 should be greater than Version2 [6]');
end;

procedure TestVersion.GreaterThanOrEqualOperatorOverloading_ShouldCompareCorrectly;
begin
  CheckTrue(TVersion.Create(111, 222, 333, 444) >=
            TVersion.Create(111, 222, 333, 444),
            'Version1 should be greater or equal than Version2 [1]');

  CheckTrue(TVersion.Create(111, 222, 333, 555) >=
            TVersion.Create(111, 222, 333, 444),
            'Version1 should be greater or equal than Version2 [2]');
end;

procedure TestVersion.ImplicitExtendedConversionWithNegativeNumber_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := -111.222;
  StopExpectingException('Negative extended number should raise an exception on implicit conversion');
end;

procedure TestVersion.ImplicitExtendedConversion_ShouldAssignMajorVersionAndMinorVersion;
begin
  Version := 111.222;
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(222, Version.MinorVersion, 'Minor version was not assigned correctly');
  CheckEquals(0, Version.Release, 'Release version was not keep 0 correctly');
  CheckEquals(0, Version.Build, 'Build version was not keep 0 correctly');
end;

procedure TestVersion.ImplicitIntegerConversionWithNegativeNumber_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := -111;
  StopExpectingException('Negative integer number should raise an exception on implicit conversion');
end;

procedure TestVersion.ImplicitIntegerConversion_ShouldAssignMajorVersion;
begin
  Version := 111;
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(0, Version.MinorVersion, 'Minor version was not keep 0 correctly');
  CheckEquals(0, Version.Release, 'Release version was not keep 0 correctly');
  CheckEquals(0, Version.Build, 'Build version was not keep 0 correctly');
end;

procedure TestVersion.ImplicitStringConversionWith1Level_ShouldAssignMajorVersion;
begin
  Version := '111';
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(0, Version.MinorVersion, 'Minor version was not keep 0 correctly');
  CheckEquals(0, Version.Release, 'Release version was not keep 0 correctly');
  CheckEquals(0, Version.Build, 'Build version was not keep 0 correctly');
end;

procedure TestVersion.ImplicitStringConversionWith2Levels_ShouldAssignMajorVersionAndMinorVersion;
begin
  Version := '111.222';
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(222, Version.MinorVersion, 'Minor version was not assigned correctly');
  CheckEquals(0, Version.Release, 'Release version was not keep 0 correctly');
  CheckEquals(0, Version.Build, 'Build version was not keep 0 correctly');
end;

procedure TestVersion.ImplicitStringConversionWith3Levels_ShouldAssignMajorVersion_MinorVersionAndRelease;
begin
  Version := '111.222.333';
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(222, Version.MinorVersion, 'Minor version was not assigned correctly');
  CheckEquals(333, Version.Release, 'Release version was not assigned correctly');
  CheckEquals(0, Version.Build, 'Build version was not keep 0 correctly');
end;

procedure TestVersion.ImplicitStringConversionWith4Levels_ShouldAssignMajorVersion_MinorVersion_ReleaseAndBuild;
begin
  Version := '111.222.333.444';
  CheckEquals(111, Version.MajorVersion, 'Major version was not assigned correctly');
  CheckEquals(222, Version.MinorVersion, 'Minor version was not assigned correctly');
  CheckEquals(333, Version.Release, 'Release version was not assigned correctly');
  CheckEquals(444, Version.Build, 'Build version was not assigned correctly');
end;

procedure TestVersion.ImplicitStringConversionWith5LevelsOrMore_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := '111.222.333.444.555';
  StopExpectingException('5 levels should raise an exception');
end;

procedure TestVersion.ImplicitStringConversionWithNegativeNumbers_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := '111.222.333.-444';
  StopExpectingException('Wrong string format should raise an exception');
end;

procedure TestVersion.ImplicitStringConversionWithLetters_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := '111.bbb.333.ddd';
  StopExpectingException('Wrong string format should raise an exception');
end;

procedure TestVersion.ImplicitStringConversionWithWrongFormat_ShouldRaiseAnException;
begin
  StartExpectingException(EVersionFormat);
  Version := 'any_invalid_input';
  StopExpectingException('Wrong string format should raise an exception');
end;

procedure TestVersion.LessThanOperatorOverloading_ShouldCompareCorrectly;
var
  Version1, Version2: TVersion;
begin
  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 555);
  CheckTrue(Version1 < Version2, 'Version1 should be less than Version2 [1]');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 444, 444);
  CheckTrue(Version1 < Version2, 'Version1 should be less than Version2 [2]');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 333, 333, 444);
  CheckTrue(Version1 < Version2, 'Version1 should be less than Version2 [3]');

  Version1 := TVersion.Create(000, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckTrue(Version1 < Version2, 'Version1 should be less than Version2 [4]');

  CheckTrue(TVersion.Create(111, 222, 333, 333) < '111.222.333.444', 'Version1 should be less than Version2 [5]');
  CheckTrue(TVersion.Create(111, 111) < 111.222, 'Version1 should be less than Version2 [6]');
end;

procedure TestVersion.LessThanOrEqualOperatorOverloading_ShouldCompareCorrectly;
begin
  CheckTrue(TVersion.Create(111, 222, 333, 444) <=
            TVersion.Create(111, 222, 333, 444),
            'Version1 should be less or equal than Version2 [1]');

  CheckTrue(TVersion.Create(111, 222, 333, 333) <=
            TVersion.Create(111, 222, 333, 444),
            'Version1 should be less or equal than Version2 [2]');
end;

procedure TestVersion.NotEqualOperatorOverloading_ShouldCompareCorrectly;
var
  Version1, Version2: TVersion;
begin
  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 444);
  CheckFalse(Version1 <> Version2, 'Versions should be equal');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(555, 666, 777, 888);
  CheckTrue(Version1 <> Version2, 'Versions should not be equal');

  Version1 := TVersion.Create(111, 222, 333, 444);
  Version2 := TVersion.Create(111, 222, 333, 555);
  CheckTrue(Version1 <> Version2, 'Versions should not be equal');

  CheckFalse(TVersion.Create(111, 222, 333, 444) <> '111.222.333.444', 'Versions should be equal');
  CheckFalse(TVersion.Create(111, 222) <> 111.222, 'Versions should be equal');
end;

procedure TestVersion.SetUp;
begin
  inherited;
  Version.Clear;
end;

initialization
  RegisterTest('HSharp.Core.Version', TestVersion.Suite);

end.

