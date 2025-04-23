/**************************************************************************/
/*	sh_interp.lua											              */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

function Plutonic.Interpolation.Lerp(a, b, c)
	return a + (b - a) * c
end

function Plutonic.Interpolation.BezierCurve(t, p0, p1, p2)
	local l1 = Plutonic.Interpolation.Lerp(p0, p1, t)
	local l2 = Plutonic.Interpolation.Lerp(p1, p2, t)
	local quad = Plutonic.Interpolation.Lerp(l1, l2, t)

	return quad
end

function Plutonic.Interpolation.VectorBezierCurve(t, v0, v1, v2)
	return Vector(Plutonic.Interpolation.BezierCurve(t, v0.x, v1.x, v2.x), Plutonic.Interpolation.BezierCurve(t, v0.y, v1.y, v2.y), Plutonic.Interpolation.BezierCurve(t, v0.z, v1.z, v2.z))
end

function Plutonic.Interpolation.AngleBezierCurve(t, a0, a1, a2)
	return Angle(Plutonic.Interpolation.BezierCurve(t, a0.p, a1.p, a2.p), Plutonic.Interpolation.BezierCurve(t, a0.y, a1.y, a2.y), Plutonic.Interpolation.BezierCurve(t, a0.r, a1.r, a2.r))
end

-- Shorthands

function Plutonic:Lerp(a, b, c)
	return Plutonic.Interpolation.Lerp(a, b, c)
end

function Plutonic:BezierCurve(t, p0, p1, p2)
	if (isvector(p0) and isvector(p1) and isvector(p2)) then
		return Plutonic.Interpolation.VectorBezierCurve(t, p0, p1, p2)
	end

	if (isangle(p0) and isangle(p1) and isangle(p2)) then
		return Plutonic.Interpolation.AngleBezierCurve(t, p0, p1, p2)
	end

	return Plutonic.Interpolation.BezierCurve(t, p0, p1, p2)
end