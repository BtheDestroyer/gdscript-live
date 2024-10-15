function updateChart(profile_results) {
    require(['https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js'], function (Chart) {
        const myChart = new Chart(document.getElementById("profiler"), {
            type: "bar",
            data: {
                labels: profile_results.map(result => result.callable),
                datasets: [
                    {
                        label: "Minimum (ms)",
                        backgroundColor: ["red", "green", "blue", "yellow", "magenta", "cyan"],
                        data: profile_results.map(result => result.min_msec)
                    },
                    {
                        label: "Average (ms)",
                        backgroundColor: ["red", "green", "blue", "yellow", "magenta", "cyan"],
                        data: profile_results.map(result => result.average_msec)
                    },
                    {
                        label: "Max (ms)",
                        backgroundColor: ["red", "green", "blue", "yellow", "magenta", "cyan"],
                        data: profile_results.map(result => result.max_msec)
                    }
                ]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    });
}
