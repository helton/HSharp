unit HSharp.Mock.Interfaces;

interface

uses
  System.Rtti;

type
  IMock<T> = interface
    ['{B74A1A0F-64CF-4E4F-B82A-46BAE8A5E880}']
  end;

  IWhen<T> = interface
    ['{7668A5DE-4A18-4AEA-BAF4-770B894BBF08}']
    function When: T;
  end;

  ISetup<T> = interface
    ['{07115CE3-C487-4E7C-985C-B1ED710F46B7}']
    function WillReturn(aValue: TValue): IWhen<T>;
  end;

implementation

end.
