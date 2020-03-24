<?php

namespace AlibabaCloud\Tea\RpcUtils;

use Adbar\Dot;
use AlibabaCloud\Tea\Model;
use AlibabaCloud\Tea\Request;

class RpcUtils
{
    public static $supportedRegionId = ['ap-southeast-1', 'ap-northeast-1', 'eu-central-1', 'cn-hongkong', 'ap-south-1'];

    public static function getEndpoint($endpoint, $useAccelerate, $endpointType = 'public')
    {
        if ('internal' == $endpointType) {
            $tmp      = explode('.', $endpoint);
            $tmp[0] .= '-internal';
            $endpoint = implode('.', $tmp);
        }
        if ($useAccelerate && 'accelerate' == $endpointType) {
            return 'oss-accelerate.aliyuncs.com';
        }

        return $endpoint;
    }

    public static function getHost($serviceCode, $regionId, $endpoint)
    {
        if (null === $endpoint || empty($endpoint)) {
            return strtolower($serviceCode) . '.' .
                strtolower($regionId) . '.' .
                'aliyuncs.com';
        }

        return $endpoint;
    }

    /**
     * @param Request $request
     * @param string  $secret
     *
     * @return string
     */
    public static function getSignature($request, $secret)
    {
        $secret .= '&';
        $strToSign = self::getStrToSign($request->method, $request->query);
        $signMethod = isset($request->query['SignatureMethod']) ? $request->query['SignatureMethod'] : "HMAC-SHA1";
        switch($signMethod){
            case 'HMAC-SHA1':
                return base64_encode(hash_hmac('sha1', $strToSign, $secret, true));
            case 'HMAC-SHA256':
                return base64_encode(hash_hmac('sha256', $strToSign, $secret, true));
            default:
                return base64_encode(hash_hmac('sha1', $strToSign, $secret, true));
        }
    }

    public static function hasError($dict)
    {
        if (null === $dict) {
            return true;
        }
        if (!isset($dict['Code'])) {
            return false;
        }

        return 'Success' != $dict['Code'];
    }

    public static function getTimestamp()
    {
        return gmdate('Y-m-d\\TH:i:s\\Z');
    }

    /**
     * @param Model $input
     * @param Model $output
     *
     * @throws \ReflectionException
     */
    public static function convert($input, &$output)
    {
        $class = new \ReflectionClass($input);
        foreach ($class->getProperties(\ReflectionProperty::IS_PUBLIC) as $property) {
            $name = $property->getName();
            if (!$property->isStatic() && isset($output->{$name})) {
                $output->{$name} = $property->getValue($input);
            }
        }
    }

    public static function query($dict)
    {
        $dot = new Dot($dict);

        return $dot->flatten();
    }

    public static function getOpenPlatFormEndpoint($endpoint, $regionId)
    {
        $regionId = strtolower($regionId);
        if (!empty($regionId) && \in_array($regionId, self::$supportedRegionId)) {
            $tmp    = explode('.', $endpoint);
            $tmp[0] .= '.' . strtolower($regionId);

            return implode('.', $tmp);
        }

        return $endpoint;
    }

    private static function getStrToSign($method, $query)
    {
        ksort($query);

        $params = [];
        foreach ($query as $k => $v) {
            if (!empty($v)) {
                //对参数名称和参数值进行 URL 编码
                $k = rawurlencode($k);
                $v = rawurlencode($v);
                //对编码后的参数名称和值使用英文等号（=）进行连接
                array_push($params, $k . '=' . $v);
            }
        }
        $str = implode('&', $params);

        return $method . '&' . rawurlencode('/') . '&' . rawurlencode($str);
    }
}
