docker pull instill/dummy-cls:test
docker pull instill/dummy-det:test
docker pull instill/dummy-image-to-image:test
docker pull instill/dummy-instance-segmentation:test
docker pull instill/dummy-keypoint:test
docker pull instill/dummy-semantic-segmentation:test
docker pull instill/dummy-text-generation:test
docker pull instill/dummy-text-generation-chat:test
docker pull instill/dummy-text-to-image:test
docker pull instill/dummy-visual-question-answering:test
docker tag instill/dummy-cls:test docker.for.mac.localhost:5001/admin/dummy-cls:test
docker tag instill/dummy-det:test docker.for.mac.localhost:5001/admin/dummy-det:test
docker tag instill/dummy-image-to-image:test docker.for.mac.localhost:5001/admin/dummy-image-to-image:test
docker tag instill/dummy-instance-segmentation:test docker.for.mac.localhost:5001/admin/dummy-instance-segmentation:test
docker tag instill/dummy-keypoint:test docker.for.mac.localhost:5001/admin/dummy-keypoint:test
docker tag instill/dummy-semantic-segmentation:test docker.for.mac.localhost:5001/admin/dummy-semantic-segmentation:test
docker tag instill/dummy-text-generation:test docker.for.mac.localhost:5001/admin/dummy-text-generation:test
docker tag instill/dummy-text-generation-chat:test docker.for.mac.localhost:5001/admin/dummy-text-generation-chat:test
docker tag instill/dummy-text-to-image:test docker.for.mac.localhost:5001/admin/dummy-text-to-image:test
docker tag instill/dummy-visual-question-answering:test docker.for.mac.localhost:5001/admin/dummy-visual-question-answering:test
docker push docker.for.mac.localhost:5001/admin/dummy-cls:test
docker push docker.for.mac.localhost:5001/admin/dummy-det:test
docker push docker.for.mac.localhost:5001/admin/dummy-image-to-image:test
docker push docker.for.mac.localhost:5001/admin/dummy-instance-segmentation:test
docker push docker.for.mac.localhost:5001/admin/dummy-keypoint:test
docker push docker.for.mac.localhost:5001/admin/dummy-semantic-segmentation:test
docker push docker.for.mac.localhost:5001/admin/dummy-text-generation:test
docker push docker.for.mac.localhost:5001/admin/dummy-text-generation-chat:test
docker push docker.for.mac.localhost:5001/admin/dummy-text-to-image:test
docker push docker.for.mac.localhost:5001/admin/dummy-visual-question-answering:test
