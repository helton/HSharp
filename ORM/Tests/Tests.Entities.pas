unit Tests.Entities;

interface

uses
  HSharp.Mapping.Attributes;

type
  [Entity]
  [Table('Users')]
  TUser = class
  private
    FId: Integer;
    FName: string;
    FEmail: string;
  public
    [Column('Id')]
    property Id: Integer read FId write FId;
    [Column('Name')]
    property Name: string read FName write FName;
    [Column('Email')]
    property Email: string read FEmail write FEmail;
  end;

  [Entity, Automapping]
  TProject = class
  private
    FId: Integer;
    FName: string;
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
  end;

implementation

end.
