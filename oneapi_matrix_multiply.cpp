//==============================================================
// Matrix Multiplication using OneAPI: SYCL
//==============================================================
// Copyright © 2024 Your Name
//
// SPDX-License-Identifier: MIT
// =============================================================

#include <CL/sycl.hpp>
#include <iostream>
#include <vector>
#include <fstream>

using namespace cl::sycl;

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <output_file>" << std::endl;
        return 1;
    }

    const size_t N = 4;

    // Inicializar matrices de entrada
    std::vector<float> matrix_a(N * N, 2.0f);
    std::vector<float> matrix_b(N * N, 3.0f);
    std::vector<float> matrix_c(N * N, 0.0f);

    try {
        // Crear un objeto queue para ejecutar tareas SYCL en el dispositivo predeterminado
        queue my_queue;

        // Crear buffers para las matrices en el dispositivo
        buffer<float, 2> buffer_a(matrix_a.data(), range<2>(N, N));
        buffer<float, 2> buffer_b(matrix_b.data(), range<2>(N, N));
        buffer<float, 2> buffer_c(matrix_c.data(), range<2>(N, N));

        // Ejecutar el kernel de multiplicación de matrices
        my_queue.submit([&](handler& h) {
            auto a = buffer_a.get_access<access::mode::read>(h);
            auto b = buffer_b.get_access<access::mode::read>(h);
            auto c = buffer_c.get_access<access::mode::write>(h);

            h.parallel_for<class matrix_multiply>(range<2>(N, N), [=](id<2> index) {
                float sum = 0.0f;
                for (size_t k = 0; k < N; ++k) {
                    sum += a[index[0]][k] * b[k][index[1]];
                }
                c[index] = sum;
            });
        });

        // Esperar a que todas las tareas en la cola se completen
        my_queue.wait();

        // Imprimir la matriz resultante
        std::ofstream output_file(argv[1]);
        for (size_t i = 0; i < N; ++i) {
            for (size_t j = 0; j < N; ++j) {
                std::cout << matrix_c[i * N + j] << " ";
                output_file << matrix_c[i * N + j] << " ";
            }
            std::cout << "\n";
            output_file << "\n";
        }
        output_file.close();
    } catch (const cl::sycl::exception& e) {
        std::cerr << "SYCL Exception: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}



