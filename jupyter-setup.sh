cat <<EOF | sudo tee /usr/local/share/jupyter/kernels/pyspark/kernel.json
{
"display_name": "PySpark",
"language": "python",
"argv": [
"/usr/bin/python2",
"-m",
"ipykernel",
"-f",
"{connection_file}"
],
"env": {
"SPARK_HOME": "/usr/local/spark-1.6.1-bin-custom-spark-final-1.6",
"PYTHONPATH": "/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/python/:/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/python/lib/py4j-0.8.2.1-src.zip",
"PYTHONSTARTUP": "/usr/local/spark-1.6.1-bin-custom-spark-final-1.6/python/pyspark/shell.py",
"PYSPARK_SUBMIT_ARGS": "--master spark://10.0.1.234:7077 pyspark-shell"
}
}
EOF
