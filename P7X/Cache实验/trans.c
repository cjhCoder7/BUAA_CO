/* transpose function of 32 x 32*/
void transpose_32x32(int M, int N, int A[N][M], int B[M][N]) {
    int t0, t1, t2, t3, t4, t5, t6, t7;

    for (int i = 0; i < N; i += 8) {
        for (int j = 0; j < M; j += 8) {
            for (int k = i; k < i + 8; k++) {
                // 先读取A中一行的数据
                t0 = A[k][j];
                t1 = A[k][j+1];
                t2 = A[k][j+2];
                t3 = A[k][j+3];
                t4 = A[k][j+4];
                t5 = A[k][j+5];
                t6 = A[k][j+6];
                t7 = A[k][j+7];

                // 写入B中对应的列
                B[j][k] = t0;
                B[j+1][k] = t1;
                B[j+2][k] = t2;
                B[j+3][k] = t3;
                B[j+4][k] = t4;
                B[j+5][k] = t5;
                B[j+6][k] = t6;
                B[j+7][k] = t7;
            }
        }
    }
}

/* transpose function of 64 x 64*/
void transpose_64x64(int M, int N, int A[N][M], int B[M][N]) {
    int t0, t1, t2, t3, t4, t5, t6, t7;

    for (int i = 0; i < N; i += 8) {
        for (int j = 0; j < M; j += 8) {
            for (int k = i; k < i + 4; k++) {
                // 取A的左上右上
                t0 = A[k][j];
                t1 = A[k][j+1];
                t2 = A[k][j+2];
                t3 = A[k][j+3];
                t4 = A[k][j+4];
                t5 = A[k][j+5];
                t6 = A[k][j+6];
                t7 = A[k][j+7];
                // 放到B的左上右上
                B[j][k] = t0;
                B[j+1][k] = t1;
                B[j+2][k] = t2;
                B[j+3][k] = t3;

                B[j][k+4] = t4;
                B[j+1][k+4] = t5;
                B[j+2][k+4] = t6;
                B[j+3][k+4] = t7;
            }
            for (int k = j; k < j + 4; k++) {
                // 临时存储B右上角的小块
                t0 = B[k][i+4];
                t1 = B[k][i+5];
                t2 = B[k][i+6];
                t3 = B[k][i+7];

                t4 = A[i+4][k];
                t5 = A[i+5][k];
                t6 = A[i+6][k];
                t7 = A[i+7][k];

                B[k][i+4] = t4;
                B[k][i+5] = t5;
                B[k][i+6] = t6;
                B[k][i+7] = t7;

                B[k+4][i] = t0;
                B[k+4][i+1] = t1;
                B[k+4][i+2] = t2;
                B[k+4][i+3] = t3;
            }
            for (int k = i + 4; k < i + 8; k++) {
                t0 = A[k][j+4];
                t1 = A[k][j+5];
                t2 = A[k][j+6];
                t3 = A[k][j+7];
                B[j+4][k] = t0;
                B[j+5][k] = t1;
                B[j+6][k] = t2;
                B[j+7][k] = t3;
            }
        }
    }
}

/* transpose function of 61 x 67*/
void transpose_61x67(int M, int N, int A[N][M], int B[M][N]) {
    int i, j, k, l;
    for (i = 0; i < N; i += 16) {
        for (j = 0; j < M; j += 16) {
            for (k = i; k < i + 16 && k < N; k++) {
                for (l = j; l < j + 16 && l < M; l++) {
                    B[l][k] = A[k][l];
                }
            }
        }
    }
}
