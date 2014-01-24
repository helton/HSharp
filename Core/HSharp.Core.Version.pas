unit HSharp.Core.Version;

interface

uses
  System.SysUtils;

type
  EVersionFormat = class(Exception);

  TVersion = record
  public
    MajorVersion: Integer;
    MinorVersion: Integer;
    Release: Integer;
    Build: Integer;
  public
    procedure Clear;
    class function Create(aMajorVersion: Integer; aMinorVersion: Integer = 0;
                          aRelease: Integer = 0; aBuild: Integer = 0):
                          TVersion; static;
    class operator Implicit(aVersion: String): TVersion;
    class operator Implicit(aVersion: Integer): TVersion;
    class operator Implicit(aVersion: Extended): TVersion;
    class operator Equal(aLeft, aRight: TVersion): Boolean;
    class operator NotEqual(aLeft, aRight: TVersion): Boolean;
    class operator LessThan(aLeft, aRight: TVersion): Boolean;
    class operator LessThanOrEqual(aLeft, aRight: TVersion): Boolean;
    class operator GreaterThan(aLeft, aRight: TVersion): Boolean;
    class operator GreaterThanOrEqual(aLeft, aRight: TVersion): Boolean;
  end;

implementation

uses
  HSharp.Core.Arrays;

{ TVersion }

procedure TVersion.Clear;
begin
  MajorVersion := 0;
  MinorVersion := 0;
  Release      := 0;
  Build        := 0;
end;

class operator TVersion.Implicit(aVersion: String): TVersion;
var
  Items: TArray<String>;

  procedure ValidateInput;
  begin
    Items.ForEach(
      procedure(const AItem: string)
      begin
        if StrToIntDef(AItem, -1) = -1 then
          raise EVersionFormat.Create(Format('Argument "%s" should be an integer', [AItem]))
        else if AItem.ToInteger < 0 then
          raise EVersionFormat.Create(Format('Argument "%s" should be a positive value', [AItem]));
      end
    );
  end;

  procedure AssignValues(var aVersion: TVersion);
  begin
    aVersion.Clear;
    if Items.Count > 0 then
      begin
        aVersion.MajorVersion := Items.Items[0].ToInteger;
        if Items.Count > 1 then
        begin
          aVersion.MinorVersion := Items.Items[1].ToInteger;
          if Items.Count > 2 then
          begin
            aVersion.Release := Items.Items[2].ToInteger;
            if Items.Count > 3 then
            begin
              aVersion.Build := Items.Items[3].ToInteger;
              if Items.Count > 4 then
                raise EVersionFormat.Create('Only 4 levels are allowed (MajorVersion[.MinorVersion[.Release[.Build]]])');
            end;
          end;
        end;
      end;
  end;

begin
  Items := TArray<String>.Create(aVersion.Split(['.']));
  ValidateInput;
  AssignValues(Result);
end;

class operator TVersion.Implicit(aVersion: Integer): TVersion;

  procedure ValidateInput;
  begin
    if aVersion < 0 then
      raise EVersionFormat.Create('Version should be a positive value');
  end;

begin
  ValidateInput;
  Result.Clear;
  Result.MajorVersion := aVersion;
end;

class function TVersion.Create(aMajorVersion, aMinorVersion, aRelease,
  aBuild: Integer): TVersion;
begin
  Result.MajorVersion := aMajorVersion;
  Result.MinorVersion := aMinorVersion;
  Result.Release      := aRelease;
  Result.Build        := aBuild;
end;

class operator TVersion.Equal(aLeft, aRight: TVersion): Boolean;
begin
  Result := (aLeft.MajorVersion = aRight.MajorVersion) and
            (aLeft.MinorVersion = aRight.MinorVersion) and
            (aLeft.Release      = aRight.Release) and
            (aLeft.Build        = aRight.Build);
end;

class operator TVersion.GreaterThan(aLeft, aRight: TVersion): Boolean;
begin
  Result := (aLeft.MajorVersion > aRight.MajorVersion) or
            (aLeft.MinorVersion > aRight.MinorVersion) or
            (aLeft.Release      > aRight.Release) or
            (aLeft.Build        > aRight.Build);
end;

class operator TVersion.GreaterThanOrEqual(aLeft, aRight: TVersion): Boolean;
begin
  Result := (aLeft > aRight) or (aLeft = aRight);
end;

class operator TVersion.Implicit(aVersion: Extended): TVersion;

  procedure ValidateInput;
  begin
    if aVersion < 0 then
      raise EVersionFormat.Create('Version should be a positive value');
  end;

begin
  ValidateInput;
  Result := aVersion.ToString.Replace(',', '.');
end;

class operator TVersion.LessThan(aLeft, aRight: TVersion): Boolean;
begin
  Result := (aLeft.MajorVersion < aRight.MajorVersion) or
            (aLeft.MinorVersion < aRight.MinorVersion) or
            (aLeft.Release      < aRight.Release) or
            (aLeft.Build        < aRight.Build);
end;

class operator TVersion.LessThanOrEqual(aLeft, aRight: TVersion): Boolean;
begin
  Result := (aLeft < aRight) or (aLeft = aRight);
end;

class operator TVersion.NotEqual(aLeft, aRight: TVersion): Boolean;
begin
  Result := not (aLeft = aRight);
end;

end.
