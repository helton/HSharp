program Calculator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  HSharp.Core.Assert,
  HSharp.Core.Benchmarker,
  Calc in 'Calc.pas';

var
  Calc: ICalc;

  procedure EvalAndWrite(const aExpression: string);
  begin
    Writeln(('"' + aExpression + '"'):20, ' = <', Calc.Evaluate(
      aExpression):10:2, '>');
  end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Calc := TCalc.Create;
//    EvalAndWrite('11111');
//    EvalAndWrite(' 222222');
//    EvalAndWrite('333333  ');
    EvalAndWrite('11+22');
    EvalAndWrite('2*5');
    EvalAndWrite('18/2');
    EvalAndWrite('11-22');
    EvalAndWrite('1-2+3-4+5-6+7');
    EvalAndWrite('5 - 8 * (123 - 545) / 4 + ');
    EvalAndWrite('11 + 22');
    EvalAndWrite(' 11 + 22');
    EvalAndWrite('11 + 22 ');
    EvalAndWrite(' 11 + 22 ');
    EvalAndWrite('   11   +    22   ');
//    EvalAndWrite('11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99+'+
//                 '11+22+33+44+55+66+77+88+99');
    Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
