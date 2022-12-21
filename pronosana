#!/usr/bin/env python3
import os
import random
import subprocess
import time
from datetime import datetime, timedelta

import typer
import json
import shutil

import webbrowser as wb

# Encoding
UTF_8 = 'utf-8'

# Modes
INIT = 'init'
BACKFILL = 'backfill'
CLEAN_UP = 'cleanup'
MODES = [INIT, BACKFILL, CLEAN_UP]

# Container names
PROMETHEUS_CONTAINER_NAME = "pronosana-prom"
THANOS_SIDECAR_CONTAINER_NAME = "pronosana-thanos-sidecar"
THANOS_QUERIER_CONTAINER_NAME = "pronosana-thanos-querier"
GRAFANA_CONTAINER_NAME = "pronosana-grafana"

# Network names
PRONOSANA_NETWORK = "pronosana-network"

# Volumes names
PRONOSANA_VOLUME = "pronosana-volume"

# Prometheus file name
PROM_CONF_FILE = f'{os.getcwd()}/temp_prom.yml'
# Thanos file name
THANOS_CONF_FILE = f'{os.getcwd()}/temp_thanos.yml'
# TEMP data dir name
TEMP_DATA_DIR = f'{os.getcwd()}/tmp_data'
# OMF File name
OMF_DATA_FILE = TEMP_DATA_DIR + "/omf_data.txt"

# Prometheus OMF file location
PROM_OMF_LOCATION = "/home"

# OMF file in prometheus
PROM_OMF_FILE = PROM_OMF_LOCATION + "/omf_data.txt"

USE_REAL_DATA = False

# Dummy CPU Values
MIN_CPU_REQUEST = 0.5
MAX_CPU_REQUEST = 2
MIN_CPU_LIMIT = 3
MAX_CPU_LIMIT = 4

# Dummy Memory Values
MIN_MEM_REQUEST = 250
MAX_MEM_REQUEST = 500
MIN_MEM_LIMIT = 350
MAX_MEM_LIMIT = 800

# JSON Keys
EXPERIMENT_NAME = "experiment_name"
CONTAINER_NAME = "container_name"
CONTAINERS = "containers"
DEPLOYMENT_NAME = "deployment_name"
DEPLOYMENTS = "deployments"
NAMESPACE = "namespace"
REQUESTS = "requests"
LIMITS = "limits"
RECOMMENDATIONS = "recommendations"
MEMORY = "memory"
CPU = "cpu"
AMOUNT = "amount"
FORMAT = "format"
CONFIG = "config"

delta_15 = timedelta(minutes=15)


def copy_omf_file_to_prometheus():
    # Remove Existing file if any
    REMOVE_FILE_IN_PROMETHEUS = [
        "docker",
        "exec",
        "-it",
        f"{PROMETHEUS_CONTAINER_NAME}",
        "rm",
        "-rf",
        f"{PROM_OMF_FILE}"
    ]
    result = subprocess.run(REMOVE_FILE_IN_PROMETHEUS, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    COPY_OMF_TO_PROMETHEUS = [
        "docker",
        "cp",
        f"{OMF_DATA_FILE}",
        f"{PROMETHEUS_CONTAINER_NAME}:{PROM_OMF_LOCATION}"
    ]
    result = subprocess.run(COPY_OMF_TO_PROMETHEUS, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))



def convert_json_to_omf(json_content):
    # check if temp dir exists
    if os.path.exists(TEMP_DATA_DIR):
        shutil.rmtree(TEMP_DATA_DIR, ignore_errors=True)
    os.makedirs(TEMP_DATA_DIR)

    omf_file_writer = open(OMF_DATA_FILE, "w")
    SIZE_OF_DATA = len(json_content)
    if USE_REAL_DATA:
        # Needs to be changed after getting timestamps
        curr_time = datetime.now() - timedelta(minutes=(SIZE_OF_DATA * 15))
    else:
        curr_time = datetime.now() - timedelta(minutes=(SIZE_OF_DATA * 15))
    standard_curr_time = curr_time
    for content in json_content:
        # Dummy Initialisation will be removed in future
        cpu_request = 5
        cpu_limit = 3
        mem_request = 100
        mem_limit = 50
        cpu_format = "cores"
        mem_format = "Mi"
        experiment_name = content[EXPERIMENT_NAME]
        deployments = content[DEPLOYMENTS]
        for deployment in deployments:
            deployment_name = deployment[DEPLOYMENT_NAME]
            namespace = deployment[NAMESPACE]
            containers = deployment[CONTAINERS]
            for container in containers:
                container_name = container[CONTAINER_NAME]
                if USE_REAL_DATA:
                    # Need to extract the cpu and mem limit values
                    cpu_request = round(float(content[RECOMMENDATIONS][CONFIG][REQUESTS][CPU][AMOUNT]), 2)
                    cpu_limit = round(float(content[RECOMMENDATIONS][CONFIG][LIMITS][CPU][AMOUNT]), 2)
                    if content[RECOMMENDATIONS][CONFIG][REQUESTS][CPU][FORMAT] is not None and content[RECOMMENDATIONS][CONFIG][REQUESTS][CPU][FORMAT] != "":
                        cpu_format = content[RECOMMENDATIONS][CONFIG][REQUESTS][CPU][FORMAT]
                    elif content[RECOMMENDATIONS][CONFIG][LIMITS][CPU][FORMAT] is not None and content[RECOMMENDATIONS][CONFIG][LIMITS][CPU][FORMAT] != "":
                        cpu_format = content[RECOMMENDATIONS][CONFIG][LIMITS][CPU][FORMAT]

                    mem_request = round(float(content[RECOMMENDATIONS][CONFIG][REQUESTS][MEMORY][AMOUNT]), 2)
                    mem_limit = round(float(content[RECOMMENDATIONS][CONFIG][LIMITS][MEMORY][AMOUNT]), 2)
                    if content[RECOMMENDATIONS][CONFIG][REQUESTS][MEMORY][FORMAT] is not None and \
                            content[RECOMMENDATIONS][CONFIG][REQUESTS][MEMORY][FORMAT] != "":
                        mem_format = content[RECOMMENDATIONS][CONFIG][REQUESTS][MEMORY][FORMAT]
                    elif content[RECOMMENDATIONS][CONFIG][LIMITS][MEMORY][FORMAT] is not None and \
                            content[RECOMMENDATIONS][CONFIG][LIMITS][MEMORY][FORMAT] != "":
                        mem_format = content[RECOMMENDATIONS][CONFIG][LIMITS][MEMORY][FORMAT]
                else:
                    # Will be removed in future
                    while cpu_request > cpu_limit:
                        cpu_request = round(random.uniform(MIN_CPU_REQUEST, MAX_CPU_REQUEST), 2)
                        cpu_limit = round(random.uniform(MIN_CPU_LIMIT, MAX_CPU_LIMIT), 2)

                    while mem_request > mem_limit:
                        mem_request = round(random.uniform(MIN_MEM_REQUEST, MAX_MEM_REQUEST), 2)
                        mem_limit = round(random.uniform(MIN_MEM_LIMIT, MAX_MEM_LIMIT), 2)

                temp_time = curr_time
                while temp_time < curr_time + delta_15:
                    LINES_TO_WRITE = []
                    LINES_TO_WRITE.append("# HELP kruize_recommendations_cpu recorded cpu & mem records\n")
                    LINES_TO_WRITE.append("# TYPE kruize_recommendations_cpu gauge\n")
                    LINES_TO_WRITE.append(f'kruize_recommendations_cpu{{resource_setting="requests",container_name="{container_name}",deployment_name="{deployment_name}",format="{cpu_format}",namespace="{namespace}",experiment_name="{experiment_name}"}} {cpu_request} {int(temp_time.timestamp())}\n')
                    LINES_TO_WRITE.append(f'kruize_recommendations_cpu{{resource_setting="limits",container_name="{container_name}",deployment_name="{deployment_name}",format="{cpu_format}",namespace="{namespace}",experiment_name="{experiment_name}"}} {cpu_limit} {int(temp_time.timestamp())}\n')
                    LINES_TO_WRITE.append("# HELP kruize_recommendations_memory recorded cpu & mem records\n")
                    LINES_TO_WRITE.append("# TYPE kruize_recommendations_memory gauge\n")
                    LINES_TO_WRITE.append(f'kruize_recommendations_memory{{resource_setting="requests",container_name="{container_name}",deployment_name="{deployment_name}",format="{mem_format}",namespace="{namespace}",experiment_name="{experiment_name}"}} {mem_request} {int(temp_time.timestamp())}\n')
                    LINES_TO_WRITE.append(f'kruize_recommendations_memory{{resource_setting="limits",container_name="{container_name}",deployment_name="{deployment_name}",format="{mem_format}",namespace="{namespace}",experiment_name="{experiment_name}"}} {mem_limit} {int(temp_time.timestamp())}\n')
                    omf_file_writer.writelines(LINES_TO_WRITE)
                    LINES_TO_WRITE.clear()
                    temp_time = temp_time + timedelta(seconds=15)
        curr_time = curr_time + delta_15
    omf_file_writer.write("# EOF")
    omf_file_writer.close()
    return True



def tmp_config_thanos(delete: bool = False):
    file_content = """
type: FILESYSTEM
config:
  directory: "/home"
prefix: ""
    """
    if delete:
        if os.path.isfile(THANOS_CONF_FILE):
            print(f'Deleting file - {THANOS_CONF_FILE}')
            os.remove(THANOS_CONF_FILE)
    else:
        fp = open(THANOS_CONF_FILE, "w")
        fp.write(file_content)
        fp.close()


def tmp_config_prometheus(delete: bool = False):
    file_content = """
# my global config
global:
  external_labels:
    cluster: eu1
    replica: 0
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"
    honor_timestamps: false
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
    """
    if delete:
        if os.path.isfile(PROM_CONF_FILE):
            print(f'Deleting file - {PROM_CONF_FILE}')
            os.remove(PROM_CONF_FILE)
    else:
        fp = open(PROM_CONF_FILE, "w")
        fp.write(file_content)
        fp.close()


def initiate_pronosana():
    time_start = datetime.now()
    print(f'[PRONOSANA INIT] -> Creating volume - {PRONOSANA_VOLUME}')
    CREATE_VOLUME = [
        'docker',
        'volume',
        'create',
        '--name',
        PRONOSANA_VOLUME
    ]
    result = subprocess.run(CREATE_VOLUME, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print(f'[PRONOSANA INIT] -> Volume {PRONOSANA_VOLUME} Created.')
    print(f'[PRONOSANA INIT] -> Creating network - {PRONOSANA_NETWORK}')
    CREATE_NETWORK = [
        'docker',
        'network',
        'create',
        PRONOSANA_NETWORK
    ]
    result = subprocess.run(CREATE_NETWORK, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print(f'[PRONOSANA INIT] -> Network {PRONOSANA_NETWORK} Created.')

    # Creating temporary configs
    tmp_config_prometheus()
    tmp_config_thanos()

    print(f'[PRONOSANA INIT] -> Creating Pronosana Containers')
    PROM_CONTAINER = [
        "docker", "run", "-d", "-u", "nobody", "--rm", f"--name={PROMETHEUS_CONTAINER_NAME}", "-v", f"{PRONOSANA_VOLUME}:/prometheus:Z", "-v",
        f"{PROM_CONF_FILE}:/etc/prometheus/prometheus.yml:Z", f"--net={PRONOSANA_NETWORK}", "-p", "9090:9090",
        "prom/prometheus", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus",
        "--storage.tsdb.allow-overlapping-blocks", "--web.console.libraries=/usr/share/prometheus/console_libraries",
        "--web.console.templates=/usr/share/prometheus/consoles", "--storage.tsdb.max-block-duration=2h",
        "--storage.tsdb.min-block-duration=2h", "--storage.tsdb.retention.time=20d",
        "--storage.tsdb.retention.size=2GB", "--web.enable-lifecycle"
    ]
    result = subprocess.run(PROM_CONTAINER, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    time.sleep(5)
    THANOS_SIDECAR_CONTAINER = [
        "docker", "run", "--rm", "-u", "nobody", "-d", f"--name={THANOS_SIDECAR_CONTAINER_NAME}", "-v", f"{PRONOSANA_VOLUME}:/prometheus:Z",
        f"--net={PRONOSANA_NETWORK}", "-v", f"{THANOS_CONF_FILE}:/home/conf/thanos_conf.yml:Z", "-p", "19090:19090",
        "thanosio/thanos:v0.29.0", "sidecar", f'--tsdb.path', f'/prometheus', f'--prometheus.url', f'http://{PROMETHEUS_CONTAINER_NAME}:9090',
        f'--objstore.config-file',  '/home/conf/thanos_conf.yml', "--http-address", "0.0.0.0:19191",
        "--grpc-address", "0.0.0.0:19090", "--shipper.upload-compacted"
    ]
    result = subprocess.run(THANOS_SIDECAR_CONTAINER, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    time.sleep(5)
    THANOS_QUERIER_CONTAINER = [
        "docker", "run", "--rm", "-u", "nobody", "-d", "--rm", f"--name={THANOS_QUERIER_CONTAINER_NAME}", f"--net={PRONOSANA_NETWORK}",
        "-p", "19192:19192", "thanosio/thanos:v0.29.0", "query", "--http-address", "0.0.0.0:19192", "--store", f"{THANOS_SIDECAR_CONTAINER_NAME}:19090"
    ]
    result = subprocess.run(THANOS_QUERIER_CONTAINER, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    time.sleep(5)
    GRAFANA_CONTAINER = [
        "docker", "run", "--rm", "-d", "-p", "3000:3000", f"--net={PRONOSANA_NETWORK}", "-v",
        f"{os.getcwd()}/grafana:/etc/grafana/provisioning/",
        f"--name={GRAFANA_CONTAINER_NAME}",
        "grafana/grafana:latest"
    ]
    result = subprocess.run(GRAFANA_CONTAINER, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    time.sleep(5)

    time_end = datetime.now()
    time_diff = time_end - time_start
    print(f'[PRONOSANA INIT] -> Init process completed in {round(time_diff.total_seconds(), 4)} secs')


def initiate_backfill(json_path: str):
    print("[PRONOSANA BACKFILL] -> Initiating backfill")
    if not os.path.exists(json_path):
        print("[PRONOSANA BACKFILL] -> Invalid JSON path. Aborting backfill")
        exit(1)
    with open(json_path, 'r') as myfile:
        data = myfile.read()

    json_content = json.loads(data)

    if 0 == len(json_content):
        print("[PRONOSANA BACKFILL] -> Invalid JSON. Aborting backfill")
        exit(1)
    success = convert_json_to_omf(json_content)
    if not success:
        print("[PRONOSANA BACKFILL] -> Error converting JSON to OpenMetrics Format. Aborting backfill")
        exit(1)
    copy_omf_file_to_prometheus()
    BACKFILL_DATA = [
        "docker",
        "exec",
        "-it",
        f"{PROMETHEUS_CONTAINER_NAME}",
        "promtool",
        "tsdb",
        "create-blocks-from",
        "openmetrics",
        f"{PROM_OMF_FILE}",
        "/prometheus"
    ]
    result = subprocess.run(BACKFILL_DATA, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))

    time.sleep(5)
    wb.open("http://localhost:3000", new=2)






def initiate_cleanup():
    time_start = datetime.now()
    print("[PRONOSANA CLEANUP] -> Cleaning Up Containers")
    STOP_CONTAINERS = [
        'docker',
        'stop',
        PROMETHEUS_CONTAINER_NAME,
        THANOS_SIDECAR_CONTAINER_NAME,
        THANOS_QUERIER_CONTAINER_NAME,
        GRAFANA_CONTAINER_NAME
    ]

    print("[PRONOSANA CLEANUP] -> Initiating to stop the pronosana containers")
    result = subprocess.run(STOP_CONTAINERS, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print("[PRONOSANA CLEANUP] -> Pronosana containers stopped")

    REMOVE_CONTAINERS = [
        'docker',
        'rm',
        PROMETHEUS_CONTAINER_NAME,
        THANOS_SIDECAR_CONTAINER_NAME,
        THANOS_QUERIER_CONTAINER_NAME,
        GRAFANA_CONTAINER_NAME
    ]

    print("[PRONOSANA CLEANUP] -> Initiating to remove the pronosana containers")
    result = subprocess.run(REMOVE_CONTAINERS, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print("[PRONOSANA CLEANUP] -> Pronosana containers removed")

    time.sleep(10)
    print("[PRONOSANA CLEANUP] -> Cleaning Up volumes")
    REMOVE_VOLUMES = [
        'docker',
        'volume',
        'rm',
        '-f',
        PRONOSANA_VOLUME
    ]

    print("[PRONOSANA CLEANUP] -> Initiating to remove the pronosana volumes")
    result = subprocess.run(REMOVE_VOLUMES, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print("[PRONOSANA CLEANUP] -> Pronosana volumes removed")

    time.sleep(10)
    print("[PRONOSANA CLEANUP] -> Cleaning Up Networks")
    REMOVE_NETWORKS = [
        'docker',
        'network',
        'rm',
        PRONOSANA_NETWORK
    ]

    print("[PRONOSANA CLEANUP] -> Initiating to remove the pronosana networks")
    result = subprocess.run(REMOVE_NETWORKS, stdout=subprocess.PIPE)
    print(result.stdout.decode(UTF_8))
    print("[PRONOSANA CLEANUP] -> Pronosana networks removed")

    print(f"[PRONOSANA CLEANUP] -> Deleting temporary prometheus conf file - {PROM_CONF_FILE}")
    tmp_config_prometheus(delete=True)
    print("[PRONOSANA CLEANUP] -> Temporary prometheus conf file removed")

    print(f"[PRONOSANA CLEANUP] -> Deleting temporary thanos conf file - {THANOS_CONF_FILE}")
    tmp_config_thanos(delete=True)
    print("[PRONOSANA CLEANUP] -> Temporary thanos conf file removed")
    time_end = datetime.now()
    time_diff = time_end - time_start
    print(f"[PRONOSANA CLEANUP] -> Clean Up Completed in {round(time_diff.total_seconds(), 4)} secs")


def main(
        mode: str = typer.Argument(...,
                                   help="Mode to run `pronosana`. Supported modes are `init`, `backfill`, `cleanup`"),
        json: str = typer.Option(None, help="JSON file path to data backfill")
):
    mode = mode.strip().lower()
    json_path = json
    if mode not in MODES:
        print(f"Invalid mode - {mode}. Supported modes are {MODES}")
        exit(1)

    if mode == INIT:
        initiate_pronosana()
    elif mode == BACKFILL:
        initiate_backfill(json_path)
    elif mode == CLEAN_UP:
        initiate_cleanup()


if __name__ == "__main__":
    typer.run(main)
