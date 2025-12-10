#!/bin/bash

# 네임스페이스 변수 (필요시)
NAMESPACE="petclinic" # 사용 중인 네임스페이스로 변경하세요.

echo "----------------- 1. WEB Ingress 삭제 시작 ---------------"
# Ingress를 먼저 삭제 (ALB 삭제 시작)
# 이 리소스가 다른 서비스와 클래스를 참조하므로 가장 먼저 삭제 요청
kubectl delete -f web-ingress-service.yaml -n $NAMESPACE
# Ingress Controller가 ALB를 정리할 시간을 충분히 줍니다.
echo "Ingress 삭제 후 20초 대기 중..."
sleep 20

echo "----------------- 2. Deployment (Pod) 삭제 시작 ----------"
# Deployment를 삭제하여 Pod를 먼저 종료
kubectl delete -f web-deployment.yaml -n $NAMESPACE
kubectl delete -f was-deployment.yaml -n $NAMESPACE
# Pod 종료를 기다립니다.
echo "Deployment 삭제 후 5초 대기 중..."
sleep 5

echo "---------------- 3. Service 삭제 시작 --------------------"
# Pod가 사라진 후 Service를 삭제
kubectl delete -f web-service.yaml -n $NAMESPACE
kubectl delete -f was-service.yaml -n $NAMESPACE
echo "Service 삭제 요청 완료."

echo "-------------------- 4. IngressClass 삭제 시작 -----------"
# Ingress가 모두 삭제된 후 (이론상), IngressClass를 삭제
kubectl delete -f ingressclass.yaml -n $NAMESPACE
echo "IngressClass 삭제 요청 완료."

# 최종 정리 및 확인을 위해 잠시 대기
sleep 10
echo "--------------------- 🚀 삭제 완료 --------------------------"

# 최종 상태 확인 (watch 명령은 스크립트 실행을 멈추므로 제거)
echo "최종 리소스 상태 확인:"
kubectl get all,ingress -n $NAMESPACE
