module float32

import math

const (
	ge_tests = [// m x n ( kernels executed )
		GeTest{ // 1 x 1 (1x1)
			x: [f32(2.0)]
			y: [f32(4.4)]
			a: [f32(10.0)]
			want: [f32(18.8)]
		},
		GeTest{ // 3 x 2 ( 2x2, 1x2 )
			x: [f32(-2.0), -3, 0]
			y: [f32(-1.1), 5]
			a: [f32(1.3), 2.4, 2.6, 2.8, -1.3, -4.3]
			want: [f32(3.5), -7.6, 5.9, -12.2, -1.3, -4.3]
		},
		GeTest{ // 3 x 3 ( 2x2, 2x1, 1x2, 1x1 )
			x: [f32(-2.0), 7, 12]
			y: [f32(-1.1), 0, 6]
			a: [f32(1.3), 2.4, 3.5, 2.6, 2.8, 3.3, -1.3, -4.3, -9.7]
			want: [f32(3.5), 2.4, -8.5, -5.1, 2.8, 45.3, -14.5, -4.3, 62.3]
		},
		GeTest{ // 5 x 3 ( 4x2, 4x1, 1x2, 1x1 )
			x: [f32(-2.0), -3, 0, 1, 2]
			y: [f32(-1.1), 5, 0]
			a: [f32(1.3), 2.4, 3.5, 2.6, 2.8, 3.3, -1.3, -4.3, -9.7, 8, 9, -10, -12, -14, -6]
			want: [f32(3.5), -7.6, 3.5, 5.9, -12.2, 3.3, -1.3, -4.3, -9.7, 6.9, 14, -10, -14.2,
				-4, -6]
		},
		GeTest{ // 3 x 6 ( 2x4, 2x2, 1x4, 1x2 )
			x: [f32(-2.0), -3, 0]
			y: [f32(-1.1), 5, 0, 9, 19, 22]
			a: [f32(1.3), 2.4, 3.5, 4.8, 1.11, -9, 2.6, 2.8, 3.3, -3.4, 6.2, -8.7, -1.3, -4.3,
				-9.7, -3.1, 8.9, 8.9]
			want: [f32(3.5), -7.6, 3.5, -13.2, -36.89, -53, 5.9, -12.2, 3.3, -30.4, -50.8, -74.7,
				-1.3, -4.3, -9.7, -3.1, 8.9, 8.9]
		},
		GeTest{ // 5 x 5 ( 4x4, 4x1, 1x4, 1x1)
			x: [f32(-2.0), 0, 2, 0, 7]
			y: [f32(-1.1), 8, 7, 3, 5]
			a: [f32(1.3), 2.4, 3.5, 2.2, 8.3, 2.6, 2.8, 3.3, 4.4, -1.5, -1.3, -4.3, -9.7, -8.8,
				6.2, 8, 9, -10, -11, 12, -12, -14, -6, -2, 4]
			want: [f32(3.5), -13.6, -10.5, -3.8, -1.7, 2.6, 2.8, 3.3, 4.4, -1.5, -3.5, 11.7, 4.3,
				-2.8, 16.2, 8, 9, -10, -11, 12, -19.700000000000003, 42, 43, 19, 39]
		},
		GeTest{ // 7 x 7 ( 4x4, 4x2, 4x1, 2x4, 2x2, 2x1, 1x4, 1x2, 1x1 ) < f32(math.nan()) test >
			x: [f32(-2.0), 8, 9, -3, -1.2, 5, 4.5]
			y: [f32(-1.1), f32(math.nan()), 19, 11, -9.22, 7, 3.3]
			a: [f32(1.3), 2.4, 3.5, 4.8, 1.11, -9, 2.2, 2.6, 2.8, 3.3, -3.4, 6.2, -8.7, 5.1, -1.3,
				-4.3, -9.7, -3.1, 8.9, 8.9, 8, 5, -2.5, 1.8, -3.6, 2.8, 4.9, 7, -1.3, -4.3, -9.7,
				-3.1, 8.9, 8.9, 8, 2.6, 2.8, 3.3, -3.4, 6.2, -8.7, 5.1, 1.3, 2.4, 3.5, 4.8, 1.11,
				-9, 2.2]
			want: [f32(3.5), f32(math.nan()), -34.5, -17.2, 19.55, -23, -4.4, -6.2, f32(math.nan()),
				155.3, 84.6, -67.56, 47.3, 31.5, -11.2, f32(math.nan()), 161.3, 95.9, -74.08, 71.9,
				37.7, 8.3, f32(math.nan()), -55.2, -36.6, 30.46, -16.1, -2.9, 0.02, f32(math.nan()),
				-32.5, -16.3, 19.964, 0.5, 4.04, -2.9, f32(math.nan()), 98.3, 51.6, -39.9, 26.3,
				21.6, -3.65, f32(math.nan()), 89, 54.3, -40.38, 22.5, 17.05]
		},
	]
)

struct GeTest {
	x    []f32
	y    []f32
	a    []f32
	want []f32
}

fn test_ger() {
	tol := f32(1e-5)

	x_gd_val, y_gd_val, a_gd_val := f32(-0.5), f32(1.5), 10
	gd_ln := 4

	for test in float32.ge_tests {
		m := test.x.len
		n := test.y.len
		for align in align2 {
			xg_ln, yg_ln, ag_ln := gd_ln + align.x, gd_ln + align.y, gd_ln + align.x ^ align.y
			xg, yg := guard_vector(test.x, x_gd_val, xg_ln), guard_vector(test.y, y_gd_val,
				yg_ln)
			x, y := xg[xg_ln..xg.len - xg_ln], yg[yg_ln..yg.len - yg_ln]
			ag := guard_vector(test.a, a_gd_val, ag_ln)
			mut a := ag[ag_ln..ag.len - ag_ln]
			alpha := f32(1)
			ger(u32(m), u32(n), alpha, x, 1, y, 1, mut a, u32(n))
			for i, w in test.want {
				assert tolerance(a[i], w, tol)
			}
		}
	}
}
