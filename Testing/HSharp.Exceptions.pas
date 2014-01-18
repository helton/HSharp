unit HSharp.Exceptions;

interface

uses
  System.SysUtils;

type
  EUnsupportedParameterizedType = class(Exception);

  ENoRttiFound = class(Exception);

implementation

end.
